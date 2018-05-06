defmodule ShipchoiceBackend.ShipmentController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    shipments = ShipchoiceDb.Repo.all(ShipchoiceDb.Shipment)
    render conn, "index.html", shipments: shipments
  end

  def upload(conn, _params) do
    render conn, "upload.html"
  end

  def do_upload(conn, _params) do
    conn
    |> put_flash(:info, "Uploaded Kerry Report")
    |> redirect(to: "/shipments/upload")
  end
end
