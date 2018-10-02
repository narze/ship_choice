defmodule ShipchoiceDb.Credits do
  alias ShipchoiceDb.{Repo, Transaction, User}

  def add_credit_to_user(amount, %User{} = user) do
    transaction =
      user
      |> Ecto.build_assoc(:transactions, %{amount: amount, balance: 0})
      |> Repo.insert()
  end

  def deduct_credit_from_user(amount, %User{} = user) do
    transaction =
      user
      |> Ecto.build_assoc(:transactions, %{amount: -amount, balance: 0})
      |> Repo.insert()
  end

  def get_user_credit(%User{} = user) do
    credit =
      user
      |> Ecto.assoc(:transactions)
      |> Repo.aggregate(:sum, :amount)

    credit || 0
  end
end
