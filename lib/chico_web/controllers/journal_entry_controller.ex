defmodule ChicoWeb.JournalEntryController do
  use ChicoWeb, :controller
  import Chico.Journals.JournalEntryGuards
  alias Chico.Journals

  @doc """
  Creates a new journal entry for today, and stores the "check-in" message.
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(%{assigns: %{current_user: user}} = conn, %{"journal_entry" => params}) do
    params = Map.merge(params, %{"date" => Date.utc_today(), "user_id" => user.id})

    case Journals.check_in(params) do
      {:ok, _journal_entry} ->
        conn
        |> put_flash(:info, "Checked-in")
        |> redirect(to: Routes.journal_entry_path(conn, :today))

      {:error, changeset} ->
        render_new(conn, changeset: changeset)
    end
  end

  @doc """
  Updates the journal entry for today with the "check-out" message.
  """
  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"journal_entry" => params}) do
    journal_entry = get_current_journal_entry(conn)

    case Journals.check_out(journal_entry, params) do
      {:ok, _journal_entry} ->
        conn
        |> put_flash(:info, "Checked-out")
        |> redirect(to: Routes.journal_entry_path(conn, :today))

      {:error, changeset} ->
        render_edit(conn, changeset: changeset, journal_entry: journal_entry)
    end
  end

  @doc """
  Displays the forms to create a journal entry for today.
  """
  @spec today(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def today(conn, _params) do
    render_today(conn, get_current_journal_entry(conn))
  end

  # ----------------------------------------------------------------------------------------------

  @spec get_current_journal_entry(Plug.Conn.t()) :: Chico.Journals.JournalEntry.t()
  defp get_current_journal_entry(%{assigns: %{current_user: user}}),
    do: Journals.get_current_journal_entry(user.id)

  @spec render_today(Plug.Conn.t(), Chico.Journals.JournalEntry.t()) :: Plug.Conn.t()
  defp render_today(conn, journal_entry) when is_not_started(journal_entry) do
    changeset = Journals.journal_entry_check_in_changeset()
    render_new(conn, changeset: changeset)
  end

  defp render_today(conn, journal_entry) when is_in_progress(journal_entry) do
    changeset = Journals.journal_entry_check_out_changeset(journal_entry)
    render_edit(conn, changeset: changeset, journal_entry: journal_entry)
  end

  defp render_today(conn, journal_entry) when is_completed(journal_entry) do
    render_show(conn, journal_entry: journal_entry)
  end

  @spec render_edit(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  defp render_edit(conn, params), do: render(conn, "edit.html", params)

  @spec render_new(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  defp render_new(conn, params), do: render(conn, "new.html", params)

  @spec render_show(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  defp render_show(conn, params), do: render(conn, "show.html", params)
end
