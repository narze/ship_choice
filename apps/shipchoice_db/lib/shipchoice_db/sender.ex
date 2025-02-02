defmodule ShipchoiceDb.Sender do
  @moduledoc """
  Ecto Schema representing senders.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias ShipchoiceDb.{Repo, Sender, Shipment, Transaction, User}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sender" do
    field :name, :string
    field :phone, :string

    timestamps()

    has_many :transactions, Transaction
    has_many :shipments, Shipment, foreign_key: :sender_phone, references: :phone
    many_to_many :users, User, join_through: "sender_user"
  end

  @doc """
  Validates sender data.

  ## Examples

      iex> changeset(%Sender{}, %{field: value})
      %Sender{}

  """
  def changeset(%Sender{} = sender, attrs \\ %{}) do
    sender
    |> cast(attrs, [
      :name,
      :phone,
    ])
    |> validate_required([:name, :phone])
    |> unique_constraint(:name)
    |> unique_constraint(:phone)
  end

  @doc """
  Get all senders
  """
  def all do
    Repo.all(Sender)
  end

  @doc """
  Retrieves a sender

  ### Examples

      iex> get(1)
      %Sender{}

  """
  def get(id) do
    Repo.get(Sender, id)
  end

  @doc """
  Creates a sender

  ### Examples

      iex> insert(%{field: value})
      {:ok, %Sender{}}

  """
  def insert(attrs) do
    changeset = Sender.changeset(%Sender{}, attrs)
    Repo.insert(changeset)
  end

  @doc """
  Counts shipments associated with sender with phone number

  ### Examples

      iex> count_shipments(sender)
      0

  """
  def count_shipments(sender) do
    query = from(s in Shipment, where: s.sender_phone == ^sender.phone)
    Repo.aggregate(query, :count, :id)
  end

  def count_messages(sender) do
    query = from(
      s in Shipment,
      left_join: m in assoc(s, :messages),
      where: s.sender_phone == ^sender.phone,
      select: count(m.id)
    )
    query |> Repo.all() |> Enum.sum()
  end

  def get_shipments(sender) do
    query = from(s in Shipment, where: s.sender_phone == ^sender.phone)
    Repo.all(query)
  end

  def search(query, ""), do: query
  def search(query, search_term) do
    wildcard = "%#{search_term}%"

    from sender in query,
      where: ilike(sender.name, ^wildcard),
      or_where: ilike(sender.phone, ^wildcard)
  end
end
