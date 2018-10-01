defmodule ShipchoiceDb.CreditsTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Credits, Repo, User}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "add_credit_to_user/2" do
    test "it creates credit transaction for user" do
      amount = 10_000
      user = insert(:user)

      assert {:ok, inserted_transaction} = Credits.add_credit_to_user(amount, user)

      user = user |> Repo.preload(:transactions)
      assert user.transactions |> length() == 1
      transaction = user.transactions |> List.first()
      assert transaction == inserted_transaction
      assert transaction.amount == amount
      assert transaction.user_id == user.id
    end
  end
end
