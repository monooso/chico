defmodule Chico.Journals.JournalEntryTest do
  use Chico.DataCase, async: true
  import Chico.Factory
  alias Chico.Journals.JournalEntry

  describe "check_in_changeset/2" do
    setup do
      user = insert(:user)

      [
        attrs: %{
          check_in: "Top of the morning.",
          date: Date.utc_today(),
          user_id: user.id
        },
        user: user
      ]
    end

    test "it returns a valid changeset when given valid data", %{attrs: attrs} do
      assert %Ecto.Changeset{valid?: true} =
               JournalEntry.check_in_changeset(%JournalEntry{}, attrs)
    end

    test "insert works when given valid data", %{attrs: attrs} do
      {:ok, %JournalEntry{}} =
        JournalEntry.check_in_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()
    end

    test "insert works if there is a journal entry for the given date belonging to a different user",
         %{attrs: attrs} do
      insert(:journal_entry, date: attrs.date)

      {:ok, %JournalEntry{}} =
        JournalEntry.check_in_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()
    end

    test "insert works if there is a journal entry for the given user on a different date",
         %{attrs: attrs, user: user} do
      insert(:journal_entry, date: Date.add(attrs.date, -1), user: user)

      {:ok, %JournalEntry{}} =
        JournalEntry.check_in_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()
    end

    test "check_in is required", %{attrs: attrs} do
      attrs = Map.delete(attrs, :check_in)

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["A check-in message is required"]} = errors_on(changeset)
    end

    test "check_in cannot be empty", %{attrs: attrs} do
      attrs = %{attrs | check_in: ""}

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["A check-in message is required"]} = errors_on(changeset)
    end

    test "check_out is ignored", %{attrs: attrs} do
      attrs = Map.put(attrs, :check_out, "Cool your heels, daddy-o")

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute Map.has_key?(changeset.changes, :check_out)
    end

    test "date is required", %{attrs: attrs} do
      attrs = Map.delete(attrs, :date)

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["can't be blank"]} = errors_on(changeset)
    end

    test "date must be a date", %{attrs: attrs} do
      attrs = %{attrs | date: "today"}

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["is invalid"]} = errors_on(changeset)
    end

    test "user_id is required", %{attrs: attrs} do
      attrs = Map.delete(attrs, :user_id)

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "insert returns a changeset error if the user does not exist", %{attrs: attrs} do
      attrs = %{attrs | user_id: 123}

      {:error, changeset} =
        JournalEntry.check_in_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()

      assert %{user: ["does not exist"]} = errors_on(changeset)
    end

    test "insert returns a changeset error if there is already a journal entry for the given date and user",
         %{attrs: attrs, user: user} do
      attrs = %{attrs | date: Date.add(Date.utc_today(), Enum.random(-100..0))}

      insert(:journal_entry, date: attrs.date, user: user)

      {:error, changeset} =
        JournalEntry.check_in_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()

      assert %{date: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "check_out_changeset/2" do
    @attrs %{check_out: "End of the evening."}

    test "it returns a valid changeset when given valid data" do
      assert %Ecto.Changeset{valid?: true} =
               JournalEntry.check_out_changeset(%JournalEntry{}, @attrs)
    end

    test "check_out is required" do
      attrs = Map.delete(@attrs, :check_out)

      changeset = JournalEntry.check_out_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_out: ["A check-out message is required"]} = errors_on(changeset)
    end

    test "check_out cannot be empty" do
      attrs = %{@attrs | check_out: ""}

      changeset = JournalEntry.check_out_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_out: ["A check-out message is required"]} = errors_on(changeset)
    end
  end

  describe "base_query/1" do
    test "it returns an Ecto.Query struct" do
      assert %Ecto.Query{} = JournalEntry.base_query()
    end
  end

  describe "where_completed/1" do
    test "it limits results to completed journal entries" do
      entry_id = insert(:journal_entry) |> Map.get(:id)

      # Red herring.
      insert(:open_journal_entry)

      entries = JournalEntry.base_query() |> JournalEntry.where_completed() |> Repo.all()

      assert 1 = Enum.count(entries)
      assert %JournalEntry{id: ^entry_id} = Enum.at(entries, 0)
    end
  end

  describe "where_date/2" do
    test "it limits results to journal entries for the given date" do
      today = Date.utc_today()
      yesterday = Date.add(today, -1)

      entry_id = insert(:journal_entry, date: today) |> Map.get(:id)
      insert(:journal_entry, date: yesterday)

      assert [%JournalEntry{id: ^entry_id}] =
               JournalEntry.base_query() |> JournalEntry.where_date(today) |> Repo.all()
    end
  end

  describe "where_user/2" do
    test "it limits results to journal entries by the given user" do
      %{id: entry_id, user_id: user_id} = insert(:journal_entry)
      insert(:journal_entry)

      assert [%JournalEntry{id: ^entry_id}] =
               JournalEntry.base_query() |> JournalEntry.where_user(user_id) |> Repo.all()
    end
  end
end
