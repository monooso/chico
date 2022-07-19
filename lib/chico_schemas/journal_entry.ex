defmodule ChicoSchemas.JournalEntry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

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
  """
  @spec check_in_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def check_in_changeset(%__MODULE__{} = journal_entry, params \\ %{}) do
    journal_entry
    |> cast(params, [:check_in, :date])
    |> validate_required([:check_in, :date])
    |> unique_constraint([:date])
  end

  @doc """
  Returns a changeset for "ending" a journal entry.
  """
  @spec check_out_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def check_out_changeset(%__MODULE__{} = journal_entry, params \\ %{}) do
    journal_entry
    |> cast(params, [:check_out])
    |> validate_required([:check_out])
  end

  @doc """
  Returns a base query, used by all other query functions.
  """
  @spec base_query() :: Ecto.Query.t()
  def base_query(), do: from(e in __MODULE__, as: :journal_entry)

  @doc """
  Restricts results to completed journal entries.
  """
  @spec where_completed(Ecto.Query.t()) :: Ecto.Query.t()
  def where_completed(query),
    do: from([journal_entry: journal_entry] in query, where: not is_nil(journal_entry.check_out))
end
