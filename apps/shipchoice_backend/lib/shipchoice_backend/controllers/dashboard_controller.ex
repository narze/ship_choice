defmodule ShipchoiceBackend.DashboardController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Repo, Shipment}

  plug(:authenticate_user)

  def index(conn, params) do
    user =
      conn.assigns[:current_user]
      |> Repo.preload(:senders)

    shipment_count =
      Shipment
      |> Shipment.from_senders(user.senders)
      |> ShipchoiceDb.Repo.aggregate(:count, :id)

    render(conn, "index.html", shipment_count: shipment_count)
  end
end
