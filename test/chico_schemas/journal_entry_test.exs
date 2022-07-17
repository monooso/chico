defmodule ChicoSchemas.JournalEntryTest do
  use Chico.DataCase, async: true
  import Chico.Factory
  alias ChicoSchemas.JournalEntry

  doctest(ChicoSchemas.JournalEntry)

  describe "check_in_changeset/2" do
    @attrs %{check_in: "Top of the morning.", date: Date.utc_today()}

    test "it returns a valid changeset when given valid data" do
      assert %Ecto.Changeset{valid?: true} =
               JournalEntry.check_in_changeset(%JournalEntry{}, @attrs)
    end

    test "check_in is required" do
      attrs = Map.delete(@attrs, :check_in)

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["can't be blank"]} = errors_on(changeset)
    end

    test "check_in cannot be empty" do
      attrs = %{@attrs | check_in: ""}

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["can't be blank"]} = errors_on(changeset)
    end

    test "check_out is ignored" do
      attrs = Map.put(@attrs, :check_out, "Cool your heels, daddy-o")

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute Map.has_key?(changeset.changes, :check_out)
    end

    test "date is required" do
      attrs = Map.delete(@attrs, :date)

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["can't be blank"]} = errors_on(changeset)
    end

    test "date must be a date" do
      attrs = %{@attrs | date: "today"}

      changeset = JournalEntry.check_in_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["is invalid"]} = errors_on(changeset)
    end

    test "insert returns a changeset error if there is already a journal entry for the given date" do
      date = Date.add(Date.utc_today(), Enum.random(-100..0))
      attrs = %{@attrs | date: date}

      insert(:journal_entry, date: date)

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
      assert %{check_out: ["can't be blank"]} = errors_on(changeset)
    end

    test "check_out cannot be empty" do
      attrs = %{@attrs | check_out: ""}

      changeset = JournalEntry.check_out_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_out: ["can't be blank"]} = errors_on(changeset)
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
end
