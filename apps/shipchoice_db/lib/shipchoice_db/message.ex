defmodule ShipchoiceDb.Message do
  @moduledoc """
  Ecto Schema representing messages.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias ShipchoiceDb.{Repo, Message, Shipment}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "message" do
    field :status, :string, default: "pending"
    field :message, :string
    field :phone, :string
    field :sent_at, :naive_datetime
    belongs_to :shipment, Shipment

    timestamps()
  end

  @doc """
  Validates message data.

  ## Examples

      iex> changeset(%Message{}, %{field: value})
      %Message{}

  """
  def changeset(%Message{} = message, attrs \\ %{}) do
    message
    |> cast(attrs, [
      :status,
      :message,
      :phone,
      :sent_at,
      :shipment_id,
    ])
    |> validate_required([:message, :phone])
  end

  @doc """
  Get all messages
  """
  def all do
    Repo.all(Message)
  end

  @doc """
  Retrieves a message

  ### Examples

      iex> get(1)
      %Message{}

  """
  def get(id) do
    Repo.get(Message, id)
  end

  @doc """
  Creates a message

  ### Examples

      iex> insert(%{field: value})
      {:ok, %Message{}}

  """
  def insert(attrs) do
    changeset = Message.changeset(%Message{}, attrs)
    Repo.insert(changeset)
  end

  def search(query, search_term) do
    wildcard = "%#{search_term}%"

    from message in query,
      where: ilike(message.message, ^wildcard)
  end
end
