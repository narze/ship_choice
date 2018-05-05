defmodule ShipchoiceBackend.ShipmentController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    shipments = ShipchoiceDb.Repo.all(ShipchoiceDb.Shipment)
    render conn, "index.html", shipments: shipments
  end
end
