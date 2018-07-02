require IEx
defmodule ShipchoiceBackend.SenderControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Shipment, SMS, Sender, Repo}
  alias ShipchoiceBackend.Messages

  import Mock

  setup do
    :ok = Sandbox.checkout(ShipchoiceDb.Repo)
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

  test "GET /senders", %{conn: conn} do
    conn = get conn, "/senders"
    assert html_response(conn, 200) =~ "All Senders"
    assert html_response(conn, 200) =~ "Add New Sender"
  end

  test "GET /senders with existing senders", %{conn: conn} do
    senders = [
      %{name: "Foo", phone: "0812345678"},
      %{name: "Bar", phone: "0898765432"},
    ]

    senders
    |> Enum.each(fn(sender) -> Sender.insert(sender) end)

    conn = get conn, "/senders"

    assert html_response(conn, 200) =~ "Foo"
    assert html_response(conn, 200) =~ "0812345678"
    assert html_response(conn, 200) =~ "Bar"
    assert html_response(conn, 200) =~ "0898765432"
  end

  test "GET /senders/new", %{conn: conn} do
    conn = get conn, "/senders/new"

    assert html_response(conn, 200) =~ "Add New Sender"
  end

  test "POST /senders", %{conn: conn} do
    conn = post conn,
                "/senders",
                %{
                  sender: %{
                    name: "Foo",
                    phone: "0812345678"
                  }
                }

    assert redirected_to(conn) == "/senders"
    assert get_flash(conn, :info) =~ "Added New Sender."

    assert length(Sender.all) == 1
  end

  test "POST /senders/:id/send_sms_to_shipments", %{conn: conn} do
    sender = %{name: "Foo", phone: "0863949474"}

    {:ok, sender} = Sender.insert(sender)

    shipment1 = shipment_fixture(%{shipment_number: "PORM000188508"})
    shipment2 = shipment_fixture(%{shipment_number: "PORM000188509"})

    with_mock Messages, [
                send_message_to_all_shipments_in_sender: fn(message, sender) -> {:ok, message} end
              ] do
      conn = post conn,
                  "/senders/#{sender.id}/send_sms_to_shipments"

      assert redirected_to(conn) == "/senders"
      assert get_flash(conn, :info) =~ "Sent SMS to 2 shipments."
      assert called Messages.send_message_to_all_shipments_in_sender(:_, :_)
    end
  end
end
