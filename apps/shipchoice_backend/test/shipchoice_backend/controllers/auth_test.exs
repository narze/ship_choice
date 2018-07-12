defmodule ShipchoiceBackend.AuthTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{User}
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
      conn = conn
      |> assign(:current_user, %User{}) |> Auth.authenticate_user([])
        refute conn.halted
    end
  end
end
