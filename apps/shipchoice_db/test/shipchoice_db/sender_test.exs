defmodule ShipchoiceDb.SenderTest do
  use ExUnit.Case
  alias ShipchoiceDb.{Shipment, Sender, Repo}
  alias Ecto.Adapters.SQL.Sandbox

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

  def sender_fixture(attrs \\ %{}) do
    {:ok, sender} =
      attrs
      |> Enum.into(%{
        name: "Manassarn Manoonchai",
        phone: "0863949474",
      })
      |> Sender.insert()

    sender
  end

  describe "insert/1" do
    test "inserts a sender" do
      sender_to_insert = %{
        name: "Manassarn Manoonchai",
        phone: "0863949474",
      }

      {:ok, inserted_sender} = Sender.insert(sender_to_insert)

      sender = Sender.get(inserted_sender.id)

      assert sender.id == inserted_sender.id
      assert sender.name == inserted_sender.name
      assert sender.phone == inserted_sender.phone
    end
  end

  describe "all/0" do
    test "gets all senders" do
      senders = Sender.all

      assert length(senders) == 0
    end
  end

  describe "get_shipments/1" do
    test "gets sender's shipments by phone number" do
      sender = sender_fixture(%{phone: "11111"})
      shipment1 = shipment_fixture(%{shipment_number: "PORM000188508", sender_phone: "11111"})
      shipment2 = shipment_fixture(%{shipment_number: "PORM000188509", sender_phone: "11111"})

      assert [shipment1, shipment2] = Sender.get_shipments(sender)
    end
  end

  describe "count_shipments/1" do
    test "counts sender's shipments by phone number" do
      sender_to_insert = %{
        name: "Manassarn Manoonchai",
        phone: "0863949474",
      }

      {:ok, inserted_sender} = Sender.insert(sender_to_insert)

      sender = Sender.get(inserted_sender.id)
      count = Sender.count_shipments(sender)

      assert count == 0
    end
  end
end
