defmodule ShipchoiceDb.SenderTest do
  use ExUnit.Case
  alias ShipchoiceDb.{Sender, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
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
