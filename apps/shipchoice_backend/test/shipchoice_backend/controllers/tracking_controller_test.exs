defmodule ShipchoiceBackend.TrackingControllerTest do
  use ShipchoiceBackend.ConnCase

  test "GET /t/:shipment_number", %{conn: conn} do
    shipment_number = "ABC123"

    conn = get(conn, "/t/#{shipment_number}")

    assert redirected_to(conn) == "https://th.kerryexpress.com/en/track/?track=#{shipment_number}"
  end
end
