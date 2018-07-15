defmodule ShipchoiceBackend.SessionController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Auth
  alias ShipchoiceDb.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case sign_in(conn, username, password) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Signed In Successfully.")
        |> redirect(to: "/")
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout()
    |> put_flash(:info, "Logged Out.")
    |> redirect(to: "/")
  end

  defp sign_in(conn, username, password) do
    case User.authenticate(username, password) do
      {:ok, user} -> {:ok, Auth.login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end
end
