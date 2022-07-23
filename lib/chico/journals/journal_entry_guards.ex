defmodule Chico.Journals.JournalEntryGuards do
  @moduledoc """
  Guard functions for working with journal entries.
  """

  alias Chico.Journals.JournalEntry

  @doc """
  Checks whether the given journal entry is complete.
  """
  defguard is_completed(journal_entry)
           when is_struct(journal_entry, JournalEntry) and
                  is_binary(journal_entry.check_in) and
                  is_binary(journal_entry.check_out)

  @doc """
  Checks whether the given journal entry is in progress.
  """
  defguard is_in_progress(journal_entry)
           when is_struct(journal_entry, JournalEntry) and
                  is_binary(journal_entry.check_in) and
                  is_nil(journal_entry.check_out)

  @doc """
  Checks whether the given journal entry is not started.
  """
  defguard is_not_started(journal_entry)
           when is_struct(journal_entry, JournalEntry) and
                  is_nil(journal_entry.check_in) and
                  is_nil(journal_entry.check_out)
end
