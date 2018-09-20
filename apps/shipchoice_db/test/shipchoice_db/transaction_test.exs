defmodule ShipchoiceDb.TransactionTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Transaction, Repo}
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
      assert transaction.user_id != nil
    end
  end
end
