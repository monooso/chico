defmodule Chico.Journals do
  alias Chico.Repo
  alias ChicoSchemas.JournalEntry

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
  Returns a list of completed journal entries.
  """
  @spec get_completed_journal_entries() :: [JournalEntry.t()]
  def get_completed_journal_entries() do
    JournalEntry.base_query()
    |> JournalEntry.where_completed()
    |> Repo.all()
  end

  @doc """
  Returns today's journal entry.

  Returns a previously created journal entry if one exists, or an empty JournalEntry struct.
  """
  @spec get_current_journal_entry() :: JournalEntry.t()
  def get_current_journal_entry() do
    case Repo.get_by(JournalEntry, date: Date.utc_today()) do
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

  @doc """
  Returns a boolean indicating whether the given journal entry is complete.
  """
  @spec journal_entry_completed?(JournalEntry.t()) :: boolean()
  def journal_entry_completed?(%JournalEntry{check_in: check_in, check_out: check_out})
      when is_binary(check_in) and is_binary(check_out),
      do: true

  def journal_entry_completed?(_), do: false

  @doc """
  Returns a boolean indicating whether the given journal entry is in progress.
  """
  @spec journal_entry_in_progress?(JournalEntry.t()) :: boolean()
  def journal_entry_in_progress?(%JournalEntry{check_in: check_in, check_out: nil})
      when is_binary(check_in),
      do: true

  def journal_entry_in_progress?(_), do: false

  @doc """
  Returns a boolean indicating whether the given journal entry is not started.
  """
  @spec journal_entry_not_started?(JournalEntry.t()) :: boolean()
  def journal_entry_not_started?(%JournalEntry{check_in: nil, check_out: nil}), do: true
  def journal_entry_not_started?(_), do: false
end
