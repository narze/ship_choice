defmodule ShipchoiceBackend.ShipmentController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages

  plug :authenticate_user

  def index(conn, params) do
    page =
      ShipchoiceDb.Shipment
      |> ShipchoiceDb.Repo.paginate(params)

    render conn, "index.html",
      shipments: page.entries,
      page: page
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
      [header | rows] = Xlsxir.get_list(table_id)
      rows = Enum.reject(rows, fn(row) -> List.first(row) == nil end)
      Xlsxir.close(table_id)

      records = rows
      |> Enum.map(
        fn(row) ->
          Enum.zip(header, row) |> Enum.into(%{})
        end
      )
      |> Enum.map(&ShipchoiceDb.Shipment.parse/1)

      num = ShipchoiceDb.Shipment.insert_list(records)

      conn
      |> put_flash(:info, "Uploaded Kerry Report. #{num} Rows Processed.")
      |> redirect(to: "/shipments")
    end
  end

  def send_message(conn, %{"id" => id}) do
    shipment = ShipchoiceDb.Shipment.get(id)
    message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name}"

    result = Messages.send_message_to_shipment(message, shipment, resend: true)
    case result do
      {:ok, _message} ->
        conn
        |> put_flash(:info, "Message Sent.")
        |> redirect(to: "/shipments")
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: "/shipments")
    end
  end
end
