defmodule ShipchoiceDb.SenderTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Repo, Sender}
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

  describe "get_shipments/1" do
    test "gets sender's shipments by phone number" do
      sender = insert(:sender, %{phone: "11111"})
      shipment1 = insert(:shipment, %{shipment_number: "PORM000188508", sender_phone: "11111"})
      shipment2 = insert(:shipment, %{shipment_number: "PORM000188509", sender_phone: "11111"})

      assert [shipment1, shipment2] == Sender.get_shipments(sender)
    end
  end

  describe "count_shipments/1" do
    test "counts sender's shipments by phone number" do
      attrs = %{
        name: "Manassarn Manoonchai",
        phone: "0863949474",
      }

      inserted_sender = insert(:sender, attrs)

      sender = Sender.get(inserted_sender.id)
      count = Sender.count_shipments(sender)

      assert count == 0
    end
  end

  describe "search/2" do
    test "returns results matched by sender name" do
      sender = insert(:sender)

      result =
        Sender
        |> Sender.search(sender.name |> String.slice(1..-2))
        |> Repo.all()

      assert result == [sender]
    end

    test "returns results matched by sender phone" do
      sender = insert(:sender)

      result =
        Sender
        |> Sender.search(sender.phone |> String.slice(1..-2))
        |> Repo.all()

      assert result == [sender]
    end
  end

  describe "sender" do
    test "has many users" do
      inserted_sender = insert(:sender, users: [build(:user)])

      sender =
        Sender.get(inserted_sender.id)
        |> Repo.preload(:users)

      assert length(sender.users) == 1
    end
  end
end
