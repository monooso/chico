defmodule ChicoWeb.JournalLive do
  use ChicoWeb, :live_view
  alias Chico.Journals

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_today()}
  end

  defp assign_today(socket), do: assign(socket, :today, Journals.get_current_journal_entry())
end
