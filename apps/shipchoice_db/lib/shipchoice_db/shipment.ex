defmodule ShipchoiceDb.Shipment do
  @moduledoc """
  Ecto Schema representing shipments.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ShipchoiceDb.{Repo, Shipment}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "shipment" do
    field :shipment_number, :string
    field :branch_code, :string
    field :sender_name, :string
    field :sender_phone, :string
    field :recipient_name, :string
    field :recipient_phone, :string
    field :recipient_address1, :string
    field :recipient_address2, :string
    field :recipient_zip, :string
    field :metadata, :map

    timestamps()
  end

  @doc """
  Validates user data.

  ## Examples

      iex> changeset(%Shipment{}, %{field: value})
      %Shipment{}

  """
  def changeset(%Shipment{} = shipment, attrs) do
    shipment
    |> cast(attrs, [
      :shipment_number,
      :branch_code,
      :sender_name,
      :sender_phone,
      :recipient_name,
      :recipient_phone,
      :recipient_address1,
      :recipient_address2,
      :recipient_zip,
      :metadata,
    ])
    |> validate_required([:shipment_number])
    |> unique_constraint(:shipment_number)
  end

  @doc """
  Retrieves a shipment

  ### Examples

      iex> get(1)
      %Shipment{}

  """
  def get(id) do
    Repo.get(Shipment, id)
  end

  @doc """
  Creates a shipment

  ### Examples

      iex> insert(%{field: value})
      {:ok, %Shipment{}}

  """
  def insert(attrs) do
    changeset = Shipment.changeset(%Shipment{}, attrs)
    Repo.insert(changeset)
  end
end
