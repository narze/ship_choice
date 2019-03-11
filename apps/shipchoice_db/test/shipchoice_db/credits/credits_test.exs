defmodule ShipchoiceDb.CreditsTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Credits, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "add_credit_to_sender/2" do
    test "it creates credit transaction for sender" do
      amount = 10_000
      sender = insert(:sender)

      assert {:ok, inserted_transaction} = Credits.add_credit_to_sender(amount, sender)

      sender = sender |> Repo.preload(:transactions)
      assert sender.transactions |> length() == 1
      transaction = sender.transactions |> List.first()
      assert transaction == inserted_transaction
      assert transaction.amount == amount
      assert transaction.sender_id == sender.id
    end
  end

  describe "deduct_credit_from_sender/2" do
    test "it creates debit transaction for sender" do
      amount = 10_000
      sender = insert(:sender)

      assert {:ok, inserted_transaction} = Credits.deduct_credit_from_sender(amount, sender)

      sender = sender |> Repo.preload(:transactions)
      assert sender.transactions |> length() == 1
      transaction = sender.transactions |> List.first()
      assert transaction == inserted_transaction
      assert transaction.amount == -amount
      assert transaction.sender_id == sender.id
    end
  end

  describe "get_sender_credit/1" do
    test "it returns sum of sender's remaining credit" do
      sender = insert(:sender)

      assert Credits.get_sender_credit(sender) == 0

      Credits.add_credit_to_sender(100, sender)

      assert Credits.get_sender_credit(sender) == 100
    end
  end
end
