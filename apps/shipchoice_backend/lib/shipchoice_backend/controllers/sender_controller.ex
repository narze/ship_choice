defmodule ShipchoiceBackend.SenderController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages

  plug :authenticate_user

  def index(conn, params) do
    page =
      ShipchoiceDb.Sender
      |> ShipchoiceDb.Repo.paginate(params)

    render conn, "index.html",
      senders: page.entries,
      page: page
  end

  def new(conn, _params) do
    changeset = ShipchoiceDb.Sender.changeset(%ShipchoiceDb.Sender{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"sender" => sender_to_insert}) do
    inserted_sender =
      sender_to_insert
      |> ShipchoiceDb.Sender.insert()

    case inserted_sender do
      {:ok, _sender} ->
        conn
        |> put_flash(:info, "Added New Sender.")
        |> redirect(to: "/senders")
      _ ->
        conn
        |> put_flash(:error, "Error occurred")
        |> redirect(to: "/senders/new")
    end
  end

  def send_message_to_shipments(conn, %{"id" => id}) do
    sender = ShipchoiceDb.Sender.get(id)
    count = ShipchoiceDb.Sender.count_shipments(sender)
    {:ok, result} = Messages.send_message_to_all_shipments_in_sender(sender)
    IO.inspect result

    conn
    |> put_flash(:info, "Sent message to #{count} shipments.")
    |> redirect(to: "/senders")
  end
end
