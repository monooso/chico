defmodule ChicoWeb.UserLiveAuth do
  import Phoenix.LiveView
  alias Chico.Accounts

  def on_mount(:default, _params, %{"user_id" => user_id} = _session, socket) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user!(user_id)
    end)
  end
end
