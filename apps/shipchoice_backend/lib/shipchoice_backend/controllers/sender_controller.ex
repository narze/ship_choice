defmodule ShipchoiceBackend.SenderController do
  use ShipchoiceBackend, :controller

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
end
