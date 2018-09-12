defmodule ShipchoiceBackend.UserControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{User, Repo}

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, user_path(conn, :index)),
        get(conn, user_path(conn, :new)),
        post(conn, user_path(conn, :create), %{"user" => %{}})
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
      user = insert(:user, name: name, username: name)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "narze"
    test "GET /users", %{conn: conn} do
      conn = get(conn, "/users")
      assert html_response(conn, 200) =~ "All Users"
      assert html_response(conn, 200) =~ "Add New User"
    end

    @tag login_as: "narze"
    test "GET /users with existing users", %{conn: conn} do
      users = [
        %{name: "Foo", username: "foo", password: "supersecret"},
        %{name: "Barz", username: "barz", password: "supersecret"}
      ]

      users
      |> Enum.each(fn user -> User.insert(user) end)

      conn = get(conn, "/users")

      assert html_response(conn, 200) =~ "Foo"
      assert html_response(conn, 200) =~ "foo"
      assert html_response(conn, 200) =~ "Barz"
      assert html_response(conn, 200) =~ "barz"
    end

    @tag login_as: "narze"
    test "GET /users with search term", %{conn: conn} do
      users = [
        %{name: "Foo", username: "foo", password: "supersecret"},
        %{name: "Barz", username: "barz", password: "supersecret"}
      ]

      users
      |> Enum.each(fn user -> User.insert(user) end)

      conn = get(conn, "/users?search=oo")

      assert html_response(conn, 200) =~ "Foo"
      assert html_response(conn, 200) =~ "foo"
      refute html_response(conn, 200) =~ "Barz"
      refute html_response(conn, 200) =~ "barz"
    end

    @tag login_as: "narze"
    test "GET /users/new", %{conn: conn} do
      conn = get(conn, "/users/new")

      assert html_response(conn, 200) =~ "Add New User"
    end

    @tag login_as: "narze"
    test "POST /users", %{conn: conn} do
      assert length(User.all()) == 1

      conn =
        post(conn, "/users", %{
          user: %{
            name: "Foo", username: "foo",
            password: "supersecret"
          }
        })

      assert redirected_to(conn) == "/users"
      assert get_flash(conn, :info) =~ "Added New User."

      assert length(User.all()) == 2
    end
  end
end
