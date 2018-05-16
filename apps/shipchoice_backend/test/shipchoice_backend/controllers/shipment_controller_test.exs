defmodule ShipchoiceBackend.ShipmentControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(ShipchoiceDb.Repo)
  end

  test "GET /shipments", %{conn: conn} do
    conn = get conn, "/shipments"
    assert html_response(conn, 200) =~ "All Shipments"
    assert html_response(conn, 200) =~ "Upload Kerry Report"
  end

  test "GET /shipments with existing shipments", %{conn: conn} do
    shipments = [
      %{shipment_number: "SHP0001"},
      %{shipment_number: "SHP0002"},
    ]

    shipments
    |> Enum.each(fn(shipment) -> ShipchoiceDb.Shipment.insert(shipment) end)

    conn = get conn, "/shipments"

    assert html_response(conn, 200) =~ "SHP0001"
    assert html_response(conn, 200) =~ "SHP0002"
  end

  test "GET /shipments/upload", %{conn: conn} do
    conn = get conn, "/shipments/upload"
    assert html_response(conn, 200) =~ "Upload Kerry Report"
  end

  test "POST /shipments/upload", %{conn: conn} do
    conn = post conn, "/shipments/upload"
    assert redirected_to(conn) == "/shipments/upload"
    assert get_flash(conn, :error) == "Kerry Report File Needed"
  end

  test "POST /shipments/upload with xlsx file", %{conn: conn} do
    upload = %Plug.Upload{
      path: "test/fixtures/kerry.xlsx",
      filename: "kerry.xlsx",
    }

    conn = post conn,
                "/shipments/upload",
                %{kerry_report: upload}

    assert redirected_to(conn) == "/shipments"
    assert get_flash(conn, :info) =~ "Uploaded Kerry Report."
    assert get_flash(conn, :info) =~ "13 Rows Processed."

    assert length(ShipchoiceDb.Shipment.all) == 13
  end
end
