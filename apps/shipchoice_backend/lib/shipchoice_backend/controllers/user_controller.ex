defmodule ShipchoiceBackend.UserController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.User

  plug(:authenticate_user)

  def index(conn, params) do
    page =
      User
      |> User.search(get_in(params, ["search"]))
      |> ShipchoiceDb.Repo.paginate(params)

    render(
      conn,
      "index.html",
      users: page.entries,
      page: page
    )
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_to_insert}) do
    inserted_user =
      user_to_insert
      |> User.insert()

    case inserted_user do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Added New User.")
        |> redirect(to: "/users")

      _ ->
        conn
        |> put_flash(:error, "Error occurred")
        |> redirect(to: "/users/new")
    end
  end
end
