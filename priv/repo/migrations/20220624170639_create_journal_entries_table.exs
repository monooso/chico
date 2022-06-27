defmodule Chico.Repo.Migrations.CreateJournalEntriesTable do
  use Ecto.Migration

  @table_name :journal_entries

  def change do
    create table(@table_name) do
      add :date, :date
      add :check_in, :text
      add :check_out, :text, null: true
      timestamps()
    end

    create unique_index(@table_name, [:date])
  end
end
