defmodule ShipchoiceBackend.MessagesTest do
  use ShipchoiceDb.DataCase

  alias ShipchoiceBackend.Messages

  import Mock
  import ShipchoiceDb.Factory

  describe "message" do
    alias ShipchoiceDb.{Message}

    @valid_attrs %{
      message: "some message",
      phone: "some phone",
      sent_at: ~N[2010-04-17 14:00:00.000000]
    }
    @update_attrs %{
      message: "some updated message",
      phone: "some updated phone",
      sent_at: ~N[2011-05-18 15:01:01.000000]
    }
    @invalid_attrs %{message: nil, phone: nil, sent_at: nil}

    test "list_message/0 returns all message" do
      message = insert(:message, @valid_attrs)
      assert Messages.list_message() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = insert(:message, @valid_attrs)
      assert Messages.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Messages.create_message(@valid_attrs)
      assert message.message == "some message"
      assert message.phone == "some phone"
      assert message.sent_at == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = insert(:message, @valid_attrs)
      assert {:ok, message} = Messages.update_message(message, @update_attrs)
      assert %Message{} = message
      assert message.message == "some updated message"
      assert message.phone == "some updated phone"
      assert message.sent_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = insert(:message, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, @invalid_attrs)
      assert message == Messages.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = insert(:message, @valid_attrs)
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = insert(:message, @valid_attrs)
      assert %Ecto.Changeset{} = Messages.change_message(message)
    end
  end

  describe "sending message to shipment recipient via message" do
    test "send_message_to_shipment/3 creates a message & send it to recipient" do
      message_to_send = "Hello"
      shipment = insert(:shipment)

      with_mock SMSSender,
        send_message: fn message_to_send, _phone_number -> {:ok, message_to_send} end do
        assert {:ok, message} = Messages.send_message_to_shipment(message_to_send, shipment)
        assert message.shipment_id == shipment.id
        assert called(SMSSender.send_message(message_to_send, shipment.recipient_phone |> Messages.transform_phone_number))
      end
    end
  end

  describe "when message already sent once" do
    test "send_message_to_shipment/3 returns error" do
      message = "Hello"
      shipment = insert(:shipment, messages: [build(:message)])

      assert {:error, "Message already sent for this shipment"} =
               Messages.send_message_to_shipment(message, shipment)
    end
  end

  describe "when having option resend: true" do
    test "send_message_to_shipment/3 creates a message" do
      message_to_send = "Hello"
      shipment = insert(:shipment)

      with_mock SMSSender,
        send_message: fn message_to_send, _phone_number -> {:ok, message_to_send} end do
        assert {:ok, message} =
                 Messages.send_message_to_shipment(message_to_send, shipment, resend: true)

        assert message.shipment_id == shipment.id
        assert called(SMSSender.send_message(message_to_send, shipment.recipient_phone |> Messages.transform_phone_number))
      end
    end
  end

  describe "sending all unsent shipments for single sender" do
    test "send_message_to_all_shipments_in_sender/1" do
      shipment1 = insert(:shipment, sender_phone: "0812345678")
      _shipment2 = insert(:shipment, sender_phone: "0812345678")
      sender = insert(:sender, phone: shipment1.sender_phone)

      with_mock SMSSender, send_message: fn message, _phone_number -> {:ok, message} end do
        assert {:ok, "Sent to 2 shipments", 2} =
                 Messages.send_message_to_all_shipments_in_sender(sender)
      end
    end

    test "when specifying limit less than shipments" do
      shipment1 = insert(:shipment, sender_phone: "0812345678")
      _shipment2 = insert(:shipment, sender_phone: "0812345678")
      sender = insert(:sender, phone: shipment1.sender_phone)

      with_mock SMSSender, send_message: fn message, _phone_number -> {:ok, message} end do
        assert {:ok, "Sent to 1 shipments", 1} =
                 Messages.send_message_to_all_shipments_in_sender(sender, 1)
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
