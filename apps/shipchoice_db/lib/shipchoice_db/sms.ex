defmodule ShipchoiceDb.SMS do
  @moduledoc """
  Ecto Schema representing SMS messages.
  """
  use Ecto.Schema
  import Ecto.{Changeset}
  alias ShipchoiceDb.{Repo, SMS, Shipment}

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
  Validates sms message data.

  ## Examples

      iex> changeset(%SMS{}, %{field: value})
      %SMS{}

  """
  def changeset(%SMS{} = sms, attrs \\ %{}) do
    sms
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
  Get all sms messages
  """
  def all do
    Repo.all(SMS)
  end

  @doc """
  Retrieves a sms

  ### Examples

      iex> get(1)
      %SMS{}

  """
  def get(id) do
    Repo.get(SMS, id)
  end

  @doc """
  Creates a sms

  ### Examples

      iex> insert(%{field: value})
      {:ok, %SMS{}}

  """
  def insert(attrs) do
    changeset = SMS.changeset(%SMS{}, attrs)
    Repo.insert(changeset)
  end
end
