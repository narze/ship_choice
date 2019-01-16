defmodule ShipchoiceBackend.DashboardControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.Repo

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, dashboard_path(conn, :index)),
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "GET /dashboard with user" do
    setup [
      :insert_user,
      :insert_sender,
      :insert_shipments,
      :login_user,
    ]

    test "renders dashboard", %{conn: conn, user: _user, sender: _sender, shipments: _shipments} do
      conn = get(conn, dashboard_path(conn, :index))
      assert html_response(conn, 200) =~ "Dashboard"
      assert html_response(conn, 200) =~ "3 Shipments"
    end
  end

  defp insert_user(%{conn: _conn}) do
    user = insert(:user)

    [user: user]
  end

  defp insert_sender(%{conn: _conn, user: user}) do
    sender = insert(:sender, users: [user])

    [sender: sender]
  end

  defp insert_shipments(%{conn: _conn, user: _user, sender: sender}) do
    shipments = insert_list(3, :shipment, sender_phone: sender.phone)

    [shipments: shipments]
  end

  defp login_user(%{conn: conn, user: user}) do
    conn = assign(conn, :current_user, user)

    [conn: conn, user: user]
  end
end
