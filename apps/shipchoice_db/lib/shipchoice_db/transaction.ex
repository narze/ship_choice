defmodule ShipchoiceDb.Transaction do
  @moduledoc """
  Ecto Schema representing transactions.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ShipchoiceDb.{Repo, Transaction, Sender}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "transaction" do
    field :amount, :integer
    field :balance, :integer
    belongs_to :sender, Sender

    timestamps()
  end

  @doc """
  Validates transaction data.

  ## Examples

      iex> changeset(%Transaction{}, %{field: value})
      %Transaction{}

  """
  def changeset(%Transaction{} = transaction, attrs \\ %{}) do
    transaction
    |> cast(attrs, [
      :amount,
      :balance,
      :sender_id,
    ])
    |> validate_required([:amount, :balance, :sender_id])
  end

  @doc """
  Get all transactions
  """
  def all do
    Repo.all(Transaction)
  end

  @doc """
  Retrieves a transaction

  ### Examples

      iex> get(1)
      %Transaction{}

  """
  def get(id) do
    Repo.get(Transaction, id)
  end

  @doc """
  Creates a transaction

  ### Examples

      iex> insert(%{field: value})
      {:ok, %Transaction{}}

  """
  def insert(attrs) do
    changeset = Transaction.changeset(%Transaction{}, attrs)
    Repo.insert(changeset)
  end
end
