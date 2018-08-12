defmodule ShipchoiceBackend.AuthTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{User, Repo}
  alias ShipchoiceBackend.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(ShipchoiceBackend.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  describe "authenticate" do
    test "authenticate_user halts when no current_user exists", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, nil)
        |> Auth.authenticate_user([])

      assert conn.halted
    end

    test "authenticate_user continues when the current_user exists", %{conn: conn} do
      conn = conn |> assign(:current_user, %User{}) |> Auth.authenticate_user([])
      refute conn.halted
    end
  end

  describe "login" do
    setup %{conn: conn} do
      :ok = Sandbox.checkout(Repo)
    end

    test "login puts user in the session", %{conn: conn} do
      user_id = Ecto.UUID.generate()

      login_conn =
        conn
        |> Auth.login(%User{id: user_id})
        |> send_resp(:ok, "")

      next_conn = get(login_conn, "/")
      assert get_session(next_conn, :user_id) == user_id
    end
  end

  describe "logout" do
    setup %{conn: conn} do
      :ok = Sandbox.checkout(Repo)
    end

    test "logout removes current user from session", %{conn: conn} do
      user_id = Ecto.UUID.generate()

      logout_conn =
        conn
        |> put_session(:user_id, user_id)
        |> Auth.logout()
        |> send_resp(:ok, "")

      next_conn = get(logout_conn, "/")
      refute get_session(next_conn, :user_id)
    end
  end
end
