defmodule ShipchoiceDb.ShipmentTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
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

  describe "insert_only_new_shipments/1" do
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
            weight: 1.06
          }
        }
      ]

      {:ok, count: 2, new: 2} = Shipment.insert_only_new_shipments(shipment_list)

      assert length(Shipment.all()) == 2
    end

    test "skips existing shipments identified by shipment number" do
      insert(:shipment, shipment_number: "PORM000188508")

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

      {:ok, count: 2, new: 1} = Shipment.insert_only_new_shipments(shipment_list)

      assert length(Shipment.all()) == 2
    end
  end

  describe "parse/1" do
    test "parse shipment data from excel" do
      shipment_data = %{
        "ReceiptNo" => "PORM180402150",
        "recipient_zipcode" => "96130",
        "sender_telephone" => "0818156308;",
        "SCL" => nil,
        "BranchName" => "Kerry Parcel Shop - The Paseo Town Ramkhamhaeng (พาซิโอรามคำแหง)",
        "recipient_address1" => "2 ม. 7 ",
        "Collect_Type" => "CASH",
        "BranchID" => "PORM",
        "TRANS" => 45,
        "payer_zipcode" => "10500",
        "ReceiptDate" => 43209.4234543171,
        "payer_address2" => "ถนนเจริญกรุง แขวงบางรัก เขตบางรัก กรุงเทพมหานคร",
        "Discount" => 0,
        "recipient_name" => "คุณ ชูลกิฟลี  ดาโอ๊ะ",
        "service_code" => "2D",
        "TaxInvoiceNo" => "TPORM18041113",
        "VasSurcharge" => 59.53,
        "recipient_address2" => "ตันหยงมัส อำเภอระแงะ นราธิวาส",
        "recipient_telephone" => "0862919243;",
        "consignment_no" => "PORM000188508",
        "PKG" => 0,
        "AM" => 0,
        "sender_name" => ".Nut Shop  (คุณ นวลจันทร์)",
        "COD" => 10.2,
        "recipient_contact_person" => "คุณ ชูลกิฟลี  ดาโอ๊ะ",
        "SEAL_NO" => nil,
        "payer_address1" => "ห้อง 906 ชั้น 9 อาคารเจ้าพระยาทาวเวอร์ 89 ซ.วัดสวนพลู ",
        "C/I" => "C",
        "INSUR" => 0,
        "QTY" => 1,
        "SAT" => 0,
        "ParcelSize" => nil,
        "ShipmentType" => "SHOP SHIPMENT",
        "Weight" => 0.106,
        "PUP" => 0,
        "DeclareValue" => 0,
        "Vat" => 0.67,
        "RAS" => 50,
        "Surcharge" => 45,
        "COD_Account_ID" => "C0818156308",
        "COD_Amount" => 340,
        "payer_telephone" => "0967878274"
      }

      expected_map = %{
        shipment_number: "PORM000188508",
        branch_code: "PORM",
        sender_name: ".Nut Shop  (คุณ นวลจันทร์)",
        sender_phone: "0818156308",
        recipient_name: "คุณ ชูลกิฟลี  ดาโอ๊ะ",
        recipient_phone: "0862919243",
        recipient_address1: "2 ม. 7 ",
        recipient_address2: "ตันหยงมัส อำเภอระแงะ นราธิวาส",
        recipient_zip: "96130",
        metadata: %{
          "AM" => 0,
          "BranchName" => "Kerry Parcel Shop - The Paseo Town Ramkhamhaeng (พาซิโอรามคำแหง)",
          "C/I" => "C",
          "COD_Account_ID" => "C0818156308",
          "COD_Amount" => 340,
          "COD" => 10.2,
          "Collect_Type" => "CASH",
          "DeclareValue" => 0,
          "Discount" => 0,
          "INSUR" => 0,
          "ParcelSize" => nil,
          "payer_address1" => "ห้อง 906 ชั้น 9 อาคารเจ้าพระยาทาวเวอร์ 89 ซ.วัดสวนพลู ",
          "payer_address2" => "ถนนเจริญกรุง แขวงบางรัก เขตบางรัก กรุงเทพมหานคร",
          "payer_telephone" => "0967878274",
          "payer_zipcode" => "10500",
          "PKG" => 0,
          "PUP" => 0,
          "QTY" => 1,
          "RAS" => 50,
          "ReceiptDate" => 43209.4234543171,
          "ReceiptNo" => "PORM180402150",
          "recipient_contact_person" => "คุณ ชูลกิฟลี  ดาโอ๊ะ",
          "SAT" => 0,
          "SCL" => nil,
          "SEAL_NO" => nil,
          "service_code" => "2D",
          "ShipmentType" => "SHOP SHIPMENT",
          "Surcharge" => 45,
          "TaxInvoiceNo" => "TPORM18041113",
          "TRANS" => 45,
          "VasSurcharge" => 59.53,
          "Vat" => 0.67,
          "Weight" => 0.106,
        }
      }

      assert Shipment.parse(shipment_data) == expected_map
    end
  end

  describe "tracking_url/1" do
    test "returns shipment's tracking url" do
      shipment = insert(:shipment)
      tracking_url =
        shipment
        |> Shipment.tracking_url()

      assert tracking_url == "http://shypchoice.com/t/#{shipment.shipment_number}"
    end
  end

  describe "search/2" do
    test "returns results matched by shipment number" do
      shipment = insert(:shipment)

      result =
        Shipment
        |> Shipment.search(shipment.shipment_number |> String.slice(1..-2))
        |> Repo.all()

      assert result == [shipment]
    end

    test "returns results matched by sender name" do
      shipment = insert(:shipment)

      result =
        Shipment
        |> Shipment.search(shipment.sender_name |> String.slice(1..-2))
        |> Repo.all()

      assert result == [shipment]
    end

    test "returns results matched by sender phone" do
      shipment = insert(:shipment)

      result =
        Shipment
        |> Shipment.search(shipment.sender_phone |> String.slice(1..-2))
        |> Repo.all()

      assert result == [shipment]
    end

    test "returns results matched by recipient name" do
      shipment = insert(:shipment)

      result =
        Shipment
        |> Shipment.search(shipment.recipient_name |> String.slice(1..-2))
        |> Repo.all()

      assert result == [shipment]
    end

    test "returns results matched by recipient phone" do
      shipment = insert(:shipment)

      result =
        Shipment
        |> Shipment.search(shipment.recipient_phone |> String.slice(1..-2))
        |> Repo.all()

      assert result == [shipment]
    end
  end

  describe "sanitize_phone/1" do
    test "removes trailing semicolon" do
      assert Shipment.sanitize_phone("0812345678;") == "0812345678"
      assert Shipment.sanitize_phone("0812345678") == "0812345678"
    end

    test "get the first one if input has more than one number" do
      assert Shipment.sanitize_phone("0959233452;0959244143;") == "0959233452"
    end

    test "skips non Thai mobile phone number" do
      assert Shipment.sanitize_phone("021234567;") == nil
      assert Shipment.sanitize_phone("038337742;") == nil
      assert Shipment.sanitize_phone("038337742;0959244143;") == "0959244143"
    end
  end

  describe "from_senders/2" do
    test "scopes shipments by senders phone number" do
      shipment = insert(:shipment, sender_phone: "0812345678")
      sender = insert(:sender, phone: "0812345678")

      result =
        Shipment
        |> Shipment.from_senders([sender])
        |> Repo.all()

      assert result == [shipment]
    end
  end

  describe "get_sender/1" do
    test "returns its sender by phone" do
      shipment = insert(:shipment, sender_phone: "0812345678")
      sender = insert(:sender, phone: "0812345678")

      assert sender == shipment |> Shipment.get_sender()
    end

    test "returns nil if shipment associates to no sender" do
      shipment = insert(:shipment, sender_phone: "0812345678")

      assert Shipment.get_sender(shipment) == nil
    end
  end
end
