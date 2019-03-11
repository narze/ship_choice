defmodule ShipchoiceBackend.SenderController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Credits, Sender, Shipment}

  plug(:authenticate_user)

  def index(conn, params) do
    page =
      Sender
      |> Sender.search(get_in(params, ["search"]))
      |> ShipchoiceDb.Repo.paginate(params)

    render(
      conn,
      "index.html",
      senders: page.entries,
      page: page
    )
  end

  def new(conn, _params) do
    changeset = Sender.changeset(%Sender{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sender" => sender_to_insert}) do
    inserted_sender =
      sender_to_insert
      |> Sender.insert()

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

  def show(conn, %{"id" => id} = params) do
    sender = Sender.get(id)
    total_shipments = Sender.count_shipments(sender)
    credits = Credits.get_sender_credit(sender)
    page =
      Shipment
      |> Shipment.from_senders([sender])
      |> ShipchoiceDb.Repo.paginate(params)

    conn
    |> render(
        "show.html",
        sender: sender,
        total_shipments: total_shipments,
        shipments: page.entries,
        page: page,
        remaining_credits: credits,
        messages_sent: Sender.count_messages(sender)
      )
  end

  def send_message_to_shipments(conn, %{"id" => id}) do
    sender = Sender.get(id)
    credits = Credits.get_sender_credit(sender)

    if credits < 1 do
      conn
      |> put_flash(:error, "Messages not sent. Insufficient credit.")
      |> redirect(to: "/senders")
    else
      {:ok, _result, count} = Messages.send_message_to_all_shipments_in_sender(sender, credits)
      Credits.deduct_credit_from_sender(count, sender)

      conn
      |> put_flash(:info, "Sent message to #{count} shipments.")
      |> redirect(to: "/senders")
    end
  end
end
