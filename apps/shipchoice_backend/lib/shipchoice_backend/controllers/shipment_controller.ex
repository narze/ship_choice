defmodule ShipchoiceBackend.ShipmentController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.Shipment

  plug(:authenticate_user)

  def index(conn, params) do
    page =
      Shipment
      |> Shipment.search(get_in(params, ["search"]))
      |> ShipchoiceDb.Repo.paginate(params)

    render(
      conn,
      "index.html",
      shipments: page.entries,
      page: page
    )
  end

  def upload(conn, _params) do
    render(conn, "upload.html")
  end

  def do_upload(conn, params) do
    unless kerry_report = params["kerry_report"] do
      conn
      |> put_flash(:error, "Kerry Report File Needed")
      |> redirect(to: "/shipments/upload")
    else
      {:ok, table_id} = Xlsxir.multi_extract(kerry_report.path, 0)
      [header | rows] = Xlsxir.get_list(table_id)
      rows = Enum.reject(rows, fn row -> List.first(row) == nil end)
      Xlsxir.close(table_id)

      records =
        rows
        |> Enum.map(fn row ->
          Enum.zip(header, row) |> Enum.into(%{})
        end)
        |> Enum.map(&Shipment.parse/1)

      {:ok, count: count, new: new} = Shipment.insert_only_new_shipments(records)

      conn
      |> put_flash(
        :info,
        "Uploaded Kerry Report. #{count} Rows Processed. #{new} Shipments Added."
      )
      |> redirect(to: "/shipments")
    end
  end

  def send_message(conn, %{"id" => id}) do
    shipment = Shipment.get(id)

    message =
      case shipment
           |> Shipment.tracking_url()
           |> URLShortener.shorten_url() do
        {:ok, tracking_url} ->
          sender_name_max_length = 70 - 26 - String.length(tracking_url)

          sliced_sender_name =
            shipment.sender_name
            |> String.to_charlist()
            |> Enum.slice(0..(sender_name_max_length - 1))
            |> to_string()

          "Kerry กำลังนำส่งพัสดุจาก #{sliced_sender_name} #{tracking_url}"

        _ ->
          sender_name_max_length = 70 - 25

          sliced_sender_name =
            shipment.sender_name
            |> String.to_charlist()
            |> Enum.slice(0..(sender_name_max_length - 1))
            |> to_string()

          "Kerry กำลังนำส่งพัสดุจาก #{sliced_sender_name}"
      end

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
