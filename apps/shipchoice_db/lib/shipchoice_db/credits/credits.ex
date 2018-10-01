defmodule ShipchoiceDb.Credits do
  alias ShipchoiceDb.{Repo, Transaction, User}

  def add_credit_to_user(amount, %User{} = user) do
    transaction =
      user
      |> Ecto.build_assoc(:transactions, %{amount: amount, balance: 0})
      |> Repo.insert()
  end
end
