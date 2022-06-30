defmodule Chico.Journals do
  alias ChicoSchemas.JournalEntry

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
