defmodule Chico.JournalsTest do
  use Chico.DataCase, async: true
  import Chico.Factory
  alias Chico.Journals
  alias Chico.Journals.JournalEntry

  describe "check_in/1" do
    test "it return an {:ok, %JournalEntry{}} tuple when given valid data" do
      assert {:ok, %JournalEntry{}} =
               Journals.check_in(%{
                 check_in: "Hola",
                 date: Date.utc_today(),
                 user_id: insert(:user) |> Map.get(:id)
               })
    end

    test "it returns an {:error, %Ecto.Changeset{}} tuple when given invalid data" do
      assert {:error, %Ecto.Changeset{}} = Journals.check_in(%{})
    end
  end

  describe "check_out/1" do
    @attrs %{check_out: "Adios"}

    test "it return an {:ok, %JournalEntry{}} tuple when given valid data" do
      journal_entry = insert(:open_journal_entry)

      assert {:ok, %JournalEntry{}} = Journals.check_out(journal_entry, @attrs)
    end

    test "it returns an {:error, %Ecto.Changeset{}} tuple when given invalid data" do
      journal_entry = insert(:open_journal_entry)

      assert {:error, %Ecto.Changeset{}} = Journals.check_out(journal_entry, %{})
    end

    test "it raises when given an unsaved journal entry" do
      assert_raise(Ecto.NoPrimaryKeyValueError, fn ->
        Journals.check_out(%JournalEntry{}, @attrs)
      end)
    end
  end

  describe "get_completed_journal_entries/0" do
    test "it returns a list of completed journal entries for the specified user" do
      user = insert(:user)
      insert_list(3, :journal_entry, user: user)

      assert 3 = Journals.get_completed_journal_entries(user.id) |> Enum.count()
    end

    test "it does not return journal entries belonging to other users" do
      user = insert(:user)
      insert_list(3, :journal_entry)

      assert Journals.get_completed_journal_entries(user.id) |> Enum.empty?()
    end

    test "it does not return open journal entries" do
      user = insert(:user)
      insert(:open_journal_entry, user: user)

      assert true = Journals.get_completed_journal_entries(user.id) |> Enum.empty?()
    end
  end

  describe "get_current_journal_entry/0" do
    test "it returns the specified user's journal entry for today, if one exists" do
      %{id: journal_entry_id, user_id: user_id} = insert(:journal_entry, date: Date.utc_today())

      assert %JournalEntry{id: ^journal_entry_id} = Journals.get_current_journal_entry(user_id)
    end

    test "it returns an empty journal entry struct if the user does no have a journal entry for today" do
      %{user_id: user_id} = insert(:journal_entry, date: Date.add(Date.utc_today(), -1))

      assert %JournalEntry{} == Journals.get_current_journal_entry(user_id)
    end

    test "it does not return another user's journal entry for today" do
      user = insert(:user)
      insert(:journal_entry, date: Date.utc_today())

      assert %JournalEntry{} == Journals.get_current_journal_entry(user.id)
    end
  end

  describe "journal_entry_check_in_changeset/0" do
    test "it returns a JournalEntry changeset" do
      assert %Ecto.Changeset{data: %JournalEntry{}} = Journals.journal_entry_check_in_changeset()
    end
  end

  describe "journal_entry_check_out_changeset/0" do
    test "it returns a JournalEntry changeset" do
      assert %Ecto.Changeset{data: %JournalEntry{}} =
               Journals.journal_entry_check_out_changeset(%JournalEntry{})
    end
  end
end
