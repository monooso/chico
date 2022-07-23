defmodule Chico.Journals.JournalEntry do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @type t() :: %__MODULE__{
          check_in: String.t() | nil,
          check_out: String.t() | nil,
          date: Date.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          user: Chico.Accounts.User.t() | Ecto.Association.NotLoaded.t()
        }

  schema "journal_entries" do
    field :check_in, :string
    field :check_out, :string
    field :date, :date
    belongs_to :user, Chico.Accounts.User

    timestamps()
  end

  @doc """
  Returns a changeset for "starting" a journal entry.
  """
  @spec check_in_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def check_in_changeset(%__MODULE__{} = journal_entry, params \\ %{}) do
    journal_entry
    |> cast(params, [:check_in, :date, :user_id])
    |> validate_required(:check_in, message: "A check-in message is required")
    |> validate_required([:date, :user_id])
    |> unique_constraint([:date, :user_id])
    |> assoc_constraint(:user)
  end

  @doc """
  Returns a changeset for "ending" a journal entry.
  """
  @spec check_out_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def check_out_changeset(%__MODULE__{} = journal_entry, params \\ %{}) do
    journal_entry
    |> cast(params, [:check_out])
    |> validate_required(:check_out, message: "A check-out message is required")
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
    do: from([journal_entry: je] in query, where: not is_nil(je.check_out))

  @doc """
  Restricts results to journal entries for the specified date.
  """
  @spec where_date(Ecto.Query.t(), Date.t()) :: Ecto.Query.t()
  def where_date(query, date), do: from([journal_entry: je] in query, where: je.date == ^date)

  @doc """
  Restricts results to journal entries belonging to the specified user.
  """
  @spec where_user(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def where_user(query, user_id),
    do: from([journal_entry: je] in query, where: je.user_id == ^user_id)
end
