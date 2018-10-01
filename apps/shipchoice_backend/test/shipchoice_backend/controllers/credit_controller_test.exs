defmodule ShipchoiceBackend.CreditControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{User, Repo}

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    user = insert(:user)
    Enum.each(
      [
        get(conn, user_credit_path(conn, :new, user)),
        post(conn, user_credit_path(conn, :create, user, %{"amount" => 100})),
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "with a signed in admin user" do
    setup %{conn: conn, login_as: name} do
      user = insert(:admin_user, name: name, username: name)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "narze"
    test "GET /users/:id/credits/new", %{conn: conn, user: user} do
      conn = get(conn, "/users/#{user.id}/credits/new")
      assert html_response(conn, 200) =~ "Add Credits"
    end

    @tag login_as: "narze"
    test "POST /users/:id/credits", %{conn: conn, user: user} do
      conn =
        post(conn, "/users/#{user.id}/credits", %{
          amount: "100"
        })

      assert redirected_to(conn) == "/users"
      assert get_flash(conn, :info) =~ "Added Credits."
    end
  end
end
