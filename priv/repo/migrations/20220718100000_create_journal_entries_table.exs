defmodule Chico.Repo.Migrations.CreateJournalEntriesTable do
  use Ecto.Migration

  @table_name :journal_entries

  def change do
    create table(@table_name) do
      add :user_id, references(:users), on_delete: :delete_all
      add :date, :date
      add :check_in, :text
      add :check_out, :text, null: true
      timestamps()
    end

    create index(@table_name, [:user_id])
    create unique_index(@table_name, [:date, :user_id])
  end
end
