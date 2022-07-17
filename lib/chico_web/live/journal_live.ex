defmodule ChicoWeb.JournalLive do
  use ChicoWeb, :live_view
  alias Chico.Journals

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_history()
     |> assign_today()
     |> assign_changeset()}
  end

  @impl true
  def handle_event("check_in", %{"journal_entry" => params}, socket) do
    params = Map.put(params, "date", Date.utc_today())

    case Journals.check_in(params) do
      {:ok, journal_entry} ->
        {:noreply, assign(socket, :today, journal_entry)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event(
        "check_out",
        %{"journal_entry" => params},
        %{assigns: %{today: journal_entry}} = socket
      ) do
    case Journals.check_out(journal_entry, params) do
      {:ok, journal_entry} ->
        {:noreply, assign(socket, :today, journal_entry)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_changeset(%{assigns: %{today: journal_entry}} = socket) do
    changeset =
      cond do
        Journals.journal_entry_not_started?(journal_entry) ->
          Journals.journal_entry_check_in_changeset()

        Journals.journal_entry_in_progress?(journal_entry) ->
          Journals.journal_entry_check_out_changeset(journal_entry)

        true ->
          nil
      end

    assign(socket, :changeset, changeset)
  end

  defp assign_history(socket),
    do: assign(socket, :history, Journals.get_completed_journal_entries())

  defp assign_today(socket), do: assign(socket, :today, Journals.get_current_journal_entry())
end
