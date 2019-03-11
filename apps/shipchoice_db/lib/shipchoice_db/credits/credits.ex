defmodule ShipchoiceDb.Credits do
  alias ShipchoiceDb.{Repo, Sender}

  def add_credit_to_sender(amount, %Sender{} = sender) do
    sender
    |> Ecto.build_assoc(:transactions, %{amount: amount, balance: 0})
    |> Repo.insert()
  end

  def deduct_credit_from_sender(amount, %Sender{} = sender) do
    sender
    |> Ecto.build_assoc(:transactions, %{amount: -amount, balance: 0})
    |> Repo.insert()
  end

  def get_sender_credit(%Sender{} = sender) do
    credit =
      sender
      |> Ecto.assoc(:transactions)
      |> Repo.aggregate(:sum, :amount)

    credit || 0
  end
end
