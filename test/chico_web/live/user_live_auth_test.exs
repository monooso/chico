defmodule ChicoWeb.UserLiveAuthTest do
  use Chico.DataCase
  import Chico.AccountsFixtures
  alias Chico.Accounts.User
  alias ChicoWeb.UserLiveAuth
  alias Phoenix.LiveView.Socket

  describe "on_mount/3" do
    test "it assigns the session user to the :current_user key in the socket" do
      %{id: user_id} = user_fixture()

      assert %Socket{assigns: %{current_user: %User{id: ^user_id}}} =
               UserLiveAuth.on_mount(:default, nil, %{"user_id" => user_id}, %Socket{})
    end

    test "it assigns nil to the :current_user key in the socket if there is no session user" do
      assert_raise(Ecto.NoResultsError, fn ->
        UserLiveAuth.on_mount(:default, nil, %{"user_id" => 123}, %Socket{})
      end)
    end
  end
end
