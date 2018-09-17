defmodule ShipchoiceBackend.MembershipControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Repo, Sender, User}

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, membership_path(conn, :new)),
        post(conn, membership_path(conn, :create), %{"membership" => %{}})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "with a signed in user" do
    setup %{conn: conn, login_as: name} do
      user = insert(:admin_user, name: name, username: name)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "narze"
    test "GET /memberships/new", %{conn: conn} do
      conn = get(conn, "/memberships/new")

      assert html_response(conn, 200) =~ "Add New Membership"
    end

    @tag login_as: "narze"
    test "POST /memberships", %{conn: conn} do
      assert length(User.all()) == 1
      assert length(Sender.all()) == 0

      conn =
        post(conn, "/memberships", %{
          membership: %{
            sender_name: "JohnnyShop",
            sender_phone: "0812345678",
            name: "John Doe",
            username: "john",
            password: "password",
          }
        })

      assert redirected_to(conn) == "/users"
      assert get_flash(conn, :info) =~ "Added New Membership."

      assert length(User.all()) == 2
      assert length(Sender.all()) == 1
    end
  end
end
