defmodule ChicoWeb.JournalLiveTest do
  use ChicoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias ChicoWeb.Router.Helpers, as: Routes

  @test_path Routes.live_path(ChicoWeb.Endpoint, ChicoWeb.JournalLive)

  describe "check-in" do
    test "it displays the check-in form, if there is no check-in today", %{conn: conn} do
      {:ok, _view, html} = live(conn, @test_path)

      assert html =~ "Check-in</button>"
    end

    test "it does not display the check-out form if there is no check-in today", %{conn: conn} do
      {:ok, _view, html} = live(conn, @test_path)

      refute html =~ "Check-out</button>"
    end

    test "it does not display the 'tomorrow' message if there is no check-in today", %{conn: conn} do
      {:ok, _view, html} = live(conn, @test_path)

      refute html =~ "See you tomorrow"
    end
  end
end
