defmodule ShipchoiceBackend.SessionControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.Repo

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "GET /sessions/new", %{conn: conn} do
    conn = get conn, "/sessions/new"
    assert html_response(conn, 200) =~ "Sign In"
  end

  test "POST /sessions", %{conn: conn} do
    {:ok, user} = ShipchoiceDb.User.insert(params_for(:user, username: "username", password: "password"))

    conn = post conn, "/sessions", %{"username" => "username", "password" => "password"}
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :info) =~ "Signed In Successfully."
  end
end
