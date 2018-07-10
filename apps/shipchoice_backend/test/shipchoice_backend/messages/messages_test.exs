defmodule ShipchoiceBackend.MessagesTest do
  use ShipchoiceDb.DataCase

  alias ShipchoiceBackend.Messages

  import Mock
  import ShipchoiceDb.Factory

  describe "sms" do
    alias ShipchoiceDb.{SMS, Shipment, Sender}

    @valid_attrs %{message: "some message", phone: "some phone", sent_at: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{message: "some updated message", phone: "some updated phone", sent_at: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{message: nil, phone: nil, sent_at: nil}

    test "list_sms/0 returns all sms" do
      sms = insert(:sms, @valid_attrs)
      assert Messages.list_sms() == [sms]
    end

    test "get_sms!/1 returns the sms with given id" do
      sms = insert(:sms, @valid_attrs)
      assert Messages.get_sms!(sms.id) == sms
    end

    test "create_sms/1 with valid data creates a sms" do
      assert {:ok, %SMS{} = sms} = Messages.create_sms(@valid_attrs)
      assert sms.message == "some message"
      assert sms.phone == "some phone"
      assert sms.sent_at == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_sms/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_sms(@invalid_attrs)
    end

    test "update_sms/2 with valid data updates the sms" do
      sms = insert(:sms, @valid_attrs)
      assert {:ok, sms} = Messages.update_sms(sms, @update_attrs)
      assert %SMS{} = sms
      assert sms.message == "some updated message"
      assert sms.phone == "some updated phone"
      assert sms.sent_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_sms/2 with invalid data returns error changeset" do
      sms = insert(:sms, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Messages.update_sms(sms, @invalid_attrs)
      assert sms == Messages.get_sms!(sms.id)
    end

    test "delete_sms/1 deletes the sms" do
      sms = insert(:sms, @valid_attrs)
      assert {:ok, %SMS{}} = Messages.delete_sms(sms)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_sms!(sms.id) end
    end

    test "change_sms/1 returns a sms changeset" do
      sms = insert(:sms, @valid_attrs)
      assert %Ecto.Changeset{} = Messages.change_sms(sms)
    end
  end

  describe "sending message to shipment recipient via sms" do
    test "send_message_to_shipment/2 creates a sms & send it to recipient" do
      message = "Hello"
      shipment = insert(:shipment)

      with_mock SMSSender, [send_message: fn(message, _phone_number) -> {:ok, message} end] do
        assert {:ok, sms} = Messages.send_message_to_shipment(message, shipment)
        assert sms.shipment_id == shipment.id
        assert called SMSSender.send_message(message, "+66812345678")
      end
    end
  end

  describe "when message already sent once" do
    test "send_message_to_shipment/2 returns error" do
      message = "Hello"
      shipment = insert(:shipment)
      _sms = shipment
      |> Ecto.build_assoc(:sms, %{message: message})
      |> Repo.insert!()

      assert {:error, "Message already sent for this shipment"}
        = Messages.send_message_to_shipment(message, shipment)
    end
  end

  describe "sending all unsent shipments for single sender" do
    test "send_message_to_all_shipments_in_sender/1" do
      shipment1 = insert(:shipment, %{shipment_number: "PORM000188508"})
      _shipment2 = insert(:shipment, %{shipment_number: "PORM000188509"})
      sender = insert(:sender, %{phone: shipment1.sender_phone})

      with_mock SMSSender, [send_message: fn(message, _phone_number) -> {:ok, message} end] do
        assert {:ok, "Sent to 2 shipments"} = Messages.send_message_to_all_shipments_in_sender(sender)
      end
    end
  end

  describe "transform_phone_number/1" do
    test "replaces leading 0 with +66" do
      assert Messages.transform_phone_number("0812345678") == "+66812345678"
    end
  end

  describe "build_shipment_message/1" do
    test "builds message for shipment with kerry url & tracking number" do
      shipment = insert(:shipment, %{shipment_number: "ABC0001"})
      message = "สินค้ากำลังนำส่งโดย Kerry Express ติดตามสถานะจาก https://shypchoice.com/t/ABC0001"
      assert Messages.build_shipment_message(shipment) == message
    end
  end
end
