defmodule ChicoSchemas.JournalEntryTest do
  use Chico.DataCase, async: true
  import Chico.Factory
  alias ChicoSchemas.JournalEntry

  doctest(ChicoSchemas.JournalEntry)

  describe "new_changeset/2" do
    @attrs %{check_in: "Top of the morning.", date: Date.utc_today()}

    test "it returns a valid changeset when given valid data" do
      assert %Ecto.Changeset{valid?: true} = JournalEntry.new_changeset(%JournalEntry{}, @attrs)
    end

    test "check_in is required" do
      attrs = Map.delete(@attrs, :check_in)

      changeset = JournalEntry.new_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["can't be blank"]} = errors_on(changeset)
    end

    test "check_in cannot be empty" do
      attrs = %{@attrs | check_in: ""}

      changeset = JournalEntry.new_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{check_in: ["can't be blank"]} = errors_on(changeset)
    end

    test "check_out is ignored" do
      attrs = Map.put(@attrs, :check_out, "Cool your heels, daddy-o")

      changeset = JournalEntry.new_changeset(%JournalEntry{}, attrs)

      refute Map.has_key?(changeset.changes, :check_out)
    end

    test "date is required" do
      attrs = Map.delete(@attrs, :date)

      changeset = JournalEntry.new_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["can't be blank"]} = errors_on(changeset)
    end

    test "date must be a date" do
      attrs = %{@attrs | date: "today"}

      changeset = JournalEntry.new_changeset(%JournalEntry{}, attrs)

      refute changeset.valid?
      assert %{date: ["is invalid"]} = errors_on(changeset)
    end

    test "insert returns a changeset error if there is already a journal entry for the given date" do
      date = Date.add(Date.utc_today(), Enum.random(-100..0))
      attrs = %{@attrs | date: date}

      insert(:journal_entry, date: date)

      {:error, changeset} =
        JournalEntry.new_changeset(%JournalEntry{}, attrs) |> Chico.Repo.insert()

      assert %{date: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
