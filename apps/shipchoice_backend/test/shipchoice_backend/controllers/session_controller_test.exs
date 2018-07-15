defmodule ShipchoiceBackend.SessionControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Repo, User}

  import ShipchoiceDb.Factory

  setup %{conn: conn} do
    :ok = Sandbox.checkout(Repo)

    conn =
      conn
      |> bypass_through(ShipchoiceBackend.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
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

  describe "logout" do
    setup %{conn: conn} do
      user_id = Ecto.UUID.generate

      conn =
        conn
        |> put_session(:user_id, user_id)

      {:ok, conn: conn, user_id: user_id}
    end

    test "DELETE /sessions", %{conn: conn, user_id: user_id} do
      conn = delete conn, "/sessions/#{user_id}"
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Logged Out."
      refute get_session(conn, :user_id)
    end
  end
end
