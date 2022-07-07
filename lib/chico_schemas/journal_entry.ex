defmodule ChicoSchemas.JournalEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          check_in: String.t() | nil,
          check_out: String.t() | nil,
          date: Date.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "journal_entries" do
    field :check_in, :string
    field :check_out, :string
    field :date, :date

    timestamps()
  end

  @doc """
  Returns a changeset for "starting" a journal entry.

  ## Examples

    iex> changeset = JournalEntry.check_in_changeset(%JournalEntry{}, %{check_in: "Hola, chico", date: Date.utc_today()})
    iex> %Ecto.Changeset{data: %JournalEntry{}, valid?: true} = changeset

    iex> changeset = JournalEntry.check_in_changeset(%JournalEntry{}, %{})
    iex> %Ecto.Changeset{data: %JournalEntry{}, valid?: false} = changeset

  """
  @spec check_in_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def check_in_changeset(%__MODULE__{} = journal_entry, params \\ %{}) do
    journal_entry
    |> cast(params, [:check_in, :date])
    |> validate_required([:check_in, :date])
    |> unique_constraint([:date])
  end
end
