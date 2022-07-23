defmodule ChicoWeb.Controllers.JournalEntryController do
  use ChicoWeb.ConnCase
  import Chico.Factory

  describe "logged-out" do
    test "a logged-out user is redirected to the login page", %{conn: conn} do
      conn = get(conn, Routes.journal_entry_path(conn, :today))

      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "today" do
    setup [:register_and_log_in_user]

    test "it displays the check-in form, if the logged-in user does not have a journal entry for today",
         %{conn: conn} do
      conn = get(conn, Routes.journal_entry_path(conn, :today))

      assert html_response(conn, 200) =~ "Check-in</button>"
    end

    test "it displays the check-out form, if the logged-in user has an in-progress journal entry for today",
         %{conn: conn, user: user} do
      insert(:open_journal_entry, date: Date.utc_today(), user: user)

      conn = get(conn, Routes.journal_entry_path(conn, :today))

      assert html_response(conn, 200) =~ "Check-out</button>"
    end

    test "it displays the check-in message, if the logged-in user has an in-progress journal entry for today",
         %{conn: conn, user: user} do
      %{check_in: message} = insert(:open_journal_entry, date: Date.utc_today(), user: user)

      conn = get(conn, Routes.journal_entry_path(conn, :today))

      assert html_response(conn, 200) =~ message
    end

    test "it displays a 'done' message, if the logged-in user has a completed journal entry for today",
         %{conn: conn, user: user} do
      insert(:journal_entry, date: Date.utc_today(), user: user)

      conn = get(conn, Routes.journal_entry_path(conn, :today))

      assert html_response(conn, 200) =~ "See you tomorrow"
    end
  end

  describe "create" do
    setup [:register_and_log_in_user]

    test "it refreshes to show the check-out form when given valid data", %{conn: conn} do
      conn =
        post(conn, Routes.journal_entry_path(conn, :create),
          journal_entry: %{check_in: "Start me up"}
        )

      assert redirected_to(conn) == Routes.journal_entry_path(conn, :today)

      conn = get(conn, Routes.journal_entry_path(conn, :today))
      assert html_response(conn, 200) =~ "Check-out"
    end

    test "it re-renders the check-in form with errors when given invalid data", %{conn: conn} do
      conn = post(conn, Routes.journal_entry_path(conn, :create), journal_entry: %{})

      html = html_response(conn, 200)

      assert html =~ "Check-in"
      assert html =~ "A check-in message is required"
    end
  end

  describe "update" do
    setup [:register_and_log_in_user, :create_open_journal_entry]

    test "it refreshes to show the 'done' message when given valid data", %{conn: conn} do
      conn =
        put(conn, Routes.journal_entry_path(conn, :update),
          journal_entry: %{check_out: "I never stop"}
        )

      assert redirected_to(conn) == Routes.journal_entry_path(conn, :today)

      conn = get(conn, Routes.journal_entry_path(conn, :today))
      assert html_response(conn, 200) =~ "See you tomorrow"
    end

    test "it re-renders the check-out form with errors when given invalid data", %{conn: conn} do
      conn = put(conn, Routes.journal_entry_path(conn, :update), journal_entry: %{})

      html = html_response(conn, 200)

      assert html =~ "Check-out"
      assert html =~ "A check-out message is required"
    end
  end

  defp create_open_journal_entry(%{user: user}) do
    [journal_entry: insert(:open_journal_entry, date: Date.utc_today(), user: user)]
  end
end
