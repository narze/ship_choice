defmodule ShipchoiceDb.ShipmentTest do
  use ExUnit.Case
  alias ShipchoiceDb.{Shipment, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "insert/1" do
    test "inserts a shipment" do
      shipment_to_insert = %{
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
      }

      {:ok, inserted_shipment} = Shipment.insert(shipment_to_insert)

      shipment = Shipment.get(inserted_shipment.id)

      assert shipment.id == inserted_shipment.id
      assert shipment.shipment_number == inserted_shipment.shipment_number
      assert shipment.branch_code == inserted_shipment.branch_code
      assert shipment.sender_phone == inserted_shipment.sender_phone
      assert shipment.recipient_name == inserted_shipment.recipient_name
      assert shipment.recipient_phone == inserted_shipment.recipient_phone
      assert shipment.recipient_address1 == inserted_shipment.recipient_address1
      assert shipment.recipient_address2 == inserted_shipment.recipient_address2
      assert shipment.recipient_zip == inserted_shipment.recipient_zip
      assert shipment.metadata["service_code"] == inserted_shipment.metadata[:service_code]
      assert shipment.metadata["weight"] == inserted_shipment.metadata[:weight]
    end
  end

  describe "all/0" do
    test "gets all shipments" do
      shipments = Shipment.all

      assert length(shipments) == 0
    end
  end

  describe "insert_list/1" do
    test "inserts list of shipments" do
      shipment_list = [
        %{
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
        },
        %{
          shipment_number: "PORM000188509",
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
        },
      ]

      shipments = Shipment.insert_list(shipment_list)

      assert length(shipments) == 2
    end
  end
end
