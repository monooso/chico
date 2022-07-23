defmodule Chico.Journals do
  @moduledoc """
  Functions for working with journals and journal entries.
  """

  alias Chico.Repo
  alias Chico.Journals.JournalEntry

  @type ok_tuple() :: {:ok, JournalEntry.t()}
  @type error_tuple() :: {:error, Ecto.Changeset.t()}
  @type ok_or_error_tuple() :: ok_tuple() | error_tuple()

  @doc """
  Creates a new journal entry, using the given params.
  """
  @spec check_in(map()) :: ok_or_error_tuple()
  def check_in(params) do
    %JournalEntry{}
    |> JournalEntry.check_in_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Completes the given journal entry, using the given params.
  """
  @spec check_out(JournalEntry.t(), map()) :: ok_or_error_tuple()
  def check_out(%JournalEntry{} = journal_entry, params) do
    journal_entry
    |> JournalEntry.check_out_changeset(params)
    |> Repo.update()
  end

  @doc """
  Returns a list of completed journal entries for the specified user.
  """
  @spec get_completed_journal_entries(integer()) :: [JournalEntry.t()]
  def get_completed_journal_entries(user_id) do
    JournalEntry.base_query()
    |> JournalEntry.where_user(user_id)
    |> JournalEntry.where_completed()
    |> Repo.all()
  end

  @doc """
  Returns today's journal entry for the specified user.

  Returns a previously created journal entry if one exists, or an empty JournalEntry struct.
  """
  @spec get_current_journal_entry(integer()) :: JournalEntry.t()
  def get_current_journal_entry(user_id) do
    journal_entry =
      JournalEntry.base_query()
      |> JournalEntry.where_user(user_id)
      |> JournalEntry.where_date(Date.utc_today())
      |> Repo.one()

    case journal_entry do
      nil -> %JournalEntry{}
      journal_entry -> journal_entry
    end
  end

  @doc """
  Returns a journal entry "check-in" changeset.
  """
  @spec journal_entry_check_in_changeset() :: Ecto.Changeset.t()
  def journal_entry_check_in_changeset() do
    JournalEntry.check_in_changeset(%JournalEntry{})
  end

  @doc """
  Returns a journal entry "check-out" changeset.
  """
  @spec journal_entry_check_out_changeset(JournalEntry.t()) :: Ecto.Changeset.t()
  def journal_entry_check_out_changeset(%JournalEntry{} = journal_entry) do
    JournalEntry.check_out_changeset(journal_entry)
  end
end
