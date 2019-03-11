defmodule ShipchoiceDb.TransactionTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.Repo
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "factory" do
    test "it works" do
      transaction = insert(:transaction)

      assert transaction.id != nil
      assert is_integer(transaction.amount)
      assert is_integer(transaction.amount)
      assert transaction.sender_id != nil
    end
  end
end
