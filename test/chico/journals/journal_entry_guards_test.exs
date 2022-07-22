defmodule Chico.Journals.JournalEntryGuardsTest do
  use Chico.DataCase, async: true
  import Chico.Journals.JournalEntryGuards
  alias Chico.Journals.JournalEntry

  describe "is_completed/1" do
    test "it returns true if the given JournalEntry struct has check-in and check-out data" do
      assert is_completed(%JournalEntry{
               check_in: "Top of the morning.",
               check_out: "End of the evening."
             })
    end

    test "it returns false if the given JournalEntry struct has neither check-in nor check-out data" do
      refute is_completed(%JournalEntry{})
    end

    test "it returns false if the given JournalEntry struct has check-in data, but not check-out data" do
      refute is_completed(%JournalEntry{check_in: "Top of the morning."})
    end

    test "it returns false if the given JournalEntry struct has check-out data, but not check-in data" do
      refute is_completed(%JournalEntry{check_out: "Something has gone terribly wrong."})
    end
  end

  describe "is_in_progress/1" do
    test "it returns true if the given JournalEntry struct has check-in data, but not check-out data" do
      assert is_in_progress(%JournalEntry{check_in: "Top of the morning."})
    end

    test "it returns false if the given JournalEntry struct has neither check-in nor check-out data" do
      refute is_in_progress(%JournalEntry{})
    end

    test "it returns false if the given JournalEntry struct has check-out data, but not check-in data" do
      refute is_in_progress(%JournalEntry{check_out: "Something has gone terribly wrong."})
    end

    test "it returns false if the given JournalEntry struct has check-in and check-out data" do
      refute is_in_progress(%JournalEntry{
               check_in: "Top of the morning.",
               check_out: "End of the evening."
             })
    end
  end

  describe "is_not_started/1" do
    test "it returns true if the given JournalEntry struct has neither check-in nor check-out data" do
      assert is_not_started(%JournalEntry{})
    end

    test "it returns false if the given JournalEntry struct has check-in data, but not check-out data" do
      refute is_not_started(%JournalEntry{check_in: "Top of the morning."})
    end

    test "it returns false if the given JournalEntry struct has check-out data, but not check-in data" do
      refute is_not_started(%JournalEntry{check_out: "Something has gone terribly wrong."})
    end

    test "it returns false if the given JournalEntry struct has check-in and check-out data" do
      refute is_not_started(%JournalEntry{
               check_in: "Top of the morning.",
               check_out: "End of the evening."
             })
    end
  end
end
