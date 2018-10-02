defmodule ShipchoiceBackend.CreditController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Credits, Sender}

  plug(:authenticate_user)
  plug(:authorize_admin)
  plug(:load_sender)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"amount" => amount}) do
    Credits.add_credit_to_sender(amount |> String.to_integer(), conn.assigns[:sender])

    conn
    |> put_flash(:info, "Added Credits.")
    |> redirect(to: "/senders")
  end

  defp load_sender(conn, _params) do
    conn
    |> assign(:sender, Sender.get(conn.params["sender_id"]))
  end
end
