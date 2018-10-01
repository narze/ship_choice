defmodule ShipchoiceBackend.CreditController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Credits, User}

  plug(:authenticate_user)
  plug(:authorize_admin)
  plug(:load_user)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"amount" => amount}) do
    Credits.add_credit_to_user(amount |> String.to_integer(), conn.assigns[:user])

    conn
    |> put_flash(:info, "Added Credits.")
    |> redirect(to: "/users")
  end

  defp load_user(conn, _params) do
    conn
    |> assign(:user, User.get(conn.params["user_id"]))
  end
end
