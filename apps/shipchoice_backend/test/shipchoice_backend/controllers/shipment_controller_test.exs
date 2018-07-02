require IEx
defmodule ShipchoiceBackend.ShipmentControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Shipment, SMS, Repo, Sender}

  import Mock

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  def shipment_fixture(attrs \\ %{}) do
    {:ok, shipment} =
      attrs
      |> Enum.into(%{
        shipment_number: "PORM000188508",
        branch_code: "PORM",
        sender_name: "Manassarn Manoonchai",
        sender_phone: "0863949474",
        recipient_name: "John Doe",
        recipient_phone: "0812345678",
        recipient_address1: "345, Sixth Avenue",
        recipient_address2: "District 51",
        recipient_zip: "12345",
        metadata: %{
          service_code: "ND",
          weight: 1.06,
        },
      })
      |> Shipment.insert()

    shipment
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

    # Upload again
    conn2 = post conn,
                "/shipments/upload",
                %{kerry_report: upload}

    assert redirected_to(conn2) == "/shipments"
    assert get_flash(conn2, :info) =~ "Uploaded Kerry Report."
    assert get_flash(conn2, :info) =~ "13 Rows Processed."

    assert length(ShipchoiceDb.Shipment.all) == 13
  end

  test "POST /shipments/:id/send_sms", %{conn: conn} do
    shipment = shipment_fixture()

    with_mock Messages,
              [send_message_to_shipment: fn(_message, %Shipment{}) -> {:ok, %SMS{}} end] do
      conn = post conn, "/shipments/#{shipment.id}/send_sms"
      assert redirected_to(conn) == "/shipments"
      assert get_flash(conn, :info) =~ "SMS Sent."
      assert called Messages.send_message_to_shipment(:_, :_)
    end
  end
end
