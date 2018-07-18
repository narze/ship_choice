defmodule ShipchoiceDb.MessageTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Message, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "insert/1" do
    test "inserts a message" do
      attrs = %{
        message: "Hello world",
        phone: "+66863949474",
      }

      inserted_message = insert(:message, attrs)

      message = Message.get(inserted_message.id)

      assert message.id == inserted_message.id
      assert message.message == inserted_message.message
      assert message.phone == inserted_message.phone
      assert message.sent_at == nil
      assert message.shipment_id == nil
      assert message.status == "pending"
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
