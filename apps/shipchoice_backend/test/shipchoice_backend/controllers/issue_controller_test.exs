defmodule ShipchoiceBackend.SenderControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Credits, Issue, Repo}
  alias ShipchoiceBackend.Messages

  import Mock
  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, issue_path(conn, :index)),
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "GET index" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "user"
    test "user is not allowed to view all issues" do
      conn = get(conn, "/issues")

      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "admin can view all issues" do
      conn = get(conn, "/issues")

      assert html_response(conn, 200) =~ "All Issues"
    end
  end
end
