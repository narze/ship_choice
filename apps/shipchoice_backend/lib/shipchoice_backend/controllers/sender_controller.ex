defmodule ShipchoiceBackend.SenderController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages

  def index(conn, _params) do
    senders = ShipchoiceDb.Sender.all
    render conn, "index.html", senders: senders
  end

  def new(conn, _params) do
    changeset = ShipchoiceDb.Sender.changeset(%ShipchoiceDb.Sender{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params) do
    inserted_sender =
      params["sender"]
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

  def send_sms_to_shipments(conn, %{"id" => id}) do
    sender = ShipchoiceDb.Sender.get(id)
    count = ShipchoiceDb.Sender.count_shipments(sender)
    {:ok, result} = Messages.send_message_to_all_shipments_in_sender("Hello", sender)
    IO.inspect result

    conn
    |> put_flash(:info, "Sent SMS to #{count} shipments.")
    |> redirect(to: "/senders")
  end
end
