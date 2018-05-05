defmodule ShipchoiceBackend.ShipmentControllerTest do
  use ShipchoiceBackend.ConnCase

  test "GET /shipments", %{conn: conn} do
    conn = get conn, "/shipments"
    assert html_response(conn, 200) =~ "All Shipments"
  end
end
