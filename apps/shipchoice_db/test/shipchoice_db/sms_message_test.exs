defmodule ShipchoiceDb.SMSMessageTest do
  use ExUnit.Case
  alias ShipchoiceDb.{SMSMessage, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "insert/1" do
    test "inserts a sms" do
      sms_to_insert = %{
        message: "Hello world",
        phone: "+66863949474",
      }

      {:ok, inserted_sms} = SMSMessage.insert(sms_to_insert)

      sms = SMSMessage.get(inserted_sms.id)

      assert sms.id == inserted_sms.id
      assert sms.message == inserted_sms.message
      assert sms.phone == inserted_sms.phone
      assert sms.sent_at == nil
      assert sms.shipment_id == nil
      assert sms.status == "pending"
    end
  end

  describe "send/1" do

  end

#   describe "all/0" do
#     test "gets all senders" do
#       senders = Sender.all

#       assert length(senders) == 0
#     end
#   end
end
