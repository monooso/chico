defmodule Chico.JournalsTest do
  use Chico.DataCase, async: true
  import Chico.Factory
  alias Chico.Journals
  alias ChicoSchemas.JournalEntry

  doctest(ChicoSchemas.JournalEntry)

  describe "get_current_journal_entry/0" do
    test "it returns the journal entry for today, if one exists" do
      journal_entry = insert(:journal_entry, date: Date.utc_today())

      assert ^journal_entry = Journals.get_current_journal_entry()
    end

    test "it returns an empty journal entry struct if there is no journal entry for today" do
      assert %JournalEntry{} == Journals.get_current_journal_entry()
    end
  end

  describe "journal_entry_completed?/1" do
    test "it returns true if the given JournalEntry has both check_in and check_out data" do
      assert Journals.journal_entry_completed?(%JournalEntry{
               check_in: "Top of the morning.",
               check_out: "End of the evening."
             })
    end

    test "it returns false if the given JournalEntry is missing check_out data" do
      refute Journals.journal_entry_completed?(%JournalEntry{check_in: "Top of the morning."})
    end

    test "it returns false if the given JournalEntry is missing check_in data" do
      refute Journals.journal_entry_completed?(%JournalEntry{check_out: "This is very wrong."})
    end
  end

  describe "journal_entry_in_progress?/1" do
    test "it returns true if the given JournalEntry has check_in data, but no check_out data" do
      assert Journals.journal_entry_in_progress?(%JournalEntry{check_in: "Top of the morning."})
    end

    test "it returns false if the given JournalEntry has both check_in and check_out data" do
      refute Journals.journal_entry_in_progress?(%JournalEntry{
               check_in: "Top of the morning.",
               check_out: "End of the evening."
             })
    end

    test "it returns false if the given JournalEntry has check_out data, but no check_in data" do
      refute Journals.journal_entry_in_progress?(%JournalEntry{
               check_out: "This should never happen."
             })
    end
  end

  describe "journal_entry_not_started?/1" do
    test "it returns true if the given JournalEntry has neither check_in data nor check_out data" do
      assert Journals.journal_entry_not_started?(%JournalEntry{})
    end

    test "it returns false if the given JournalEntry has check_in data" do
      refute Journals.journal_entry_not_started?(%JournalEntry{check_in: "In progress."})
    end

    test "it returns false if the given JournalEntry has check_out data" do
      refute Journals.journal_entry_not_started?(%JournalEntry{check_out: "Invalid."})
    end
  end
end
