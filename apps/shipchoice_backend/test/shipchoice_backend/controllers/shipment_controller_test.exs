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
end
