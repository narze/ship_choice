defmodule ShipchoiceBackend.ShipmentController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    shipments = ShipchoiceDb.Repo.all(ShipchoiceDb.Shipment)
    render conn, "index.html", shipments: shipments
  end

  def upload(conn, _params) do
    render conn, "upload.html"
  end

  def do_upload(conn, params) do
    unless kerry_report = params["kerry_report"] do
      conn
      |> put_flash(:error, "Kerry Report File Needed")
      |> redirect(to: "/shipments/upload")
    else
      {:ok, table_id} = Xlsxir.multi_extract(kerry_report.path, 0)
      [_header | rows] = Xlsxir.get_list(table_id)
      rows = Enum.reject(rows, fn(row) -> List.first(row) == nil end)
      Xlsxir.close(table_id)

      conn
      |> put_flash(:info, "Uploaded Kerry Report. #{length(rows)} Rows Processed.")
      |> redirect(to: "/shipments/upload")
    end
  end
end
