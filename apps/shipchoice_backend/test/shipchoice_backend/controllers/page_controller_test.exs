defmodule ShipchoiceBackend.PageControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.Repo

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "GET /" do
    test "renders index with welcome message", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Welcome to ShypChoice!"
    end

    test "renders link to sender when logged in and owned a sender", %{conn: conn} do
      user = insert(:user)
      sender = insert(:sender, users: [user])
      conn = assign(conn, :current_user, user)

      conn = get(conn, "/")
      assert html_response(conn, 200) =~ sender.name
    end
  end
end
