defmodule ShipchoiceDb.Shipment do
  @moduledoc """
  Ecto Schema representing shipments.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ShipchoiceDb.{Repo, Shipment, Message}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

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
    has_many :messages, Message

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
  Get all shipments
  """
  def all do
    Repo.all(Shipment)
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

  @doc """
  Inserts list of shipments
  """
  def insert_list(shipment_list) do
    changesets =
      shipment_list
      |> Enum.map(&add_timestamps/1)
      |> Enum.map(fn shipment ->
         Shipment.changeset(%Shipment{}, shipment)
      end)

    result = changesets
             |> Enum.with_index()
             |> Enum.reduce(Ecto.Multi.new(), fn ({changeset, index}, multi) ->
                Ecto.Multi.insert_or_update(
                  multi,
                  Integer.to_string(index),
                  changeset,
                  on_conflict: :replace_all,
                  conflict_target: :shipment_number
                )
             end)
             |> Repo.transaction

    case result do
      {:ok, multiple_shipment_result} ->
        Enum.count(multiple_shipment_result)
      _ ->
        0
    end
  end

  defp add_timestamps(row) do
    row
    |> Map.put(:inserted_at, DateTime.utc_now)
    |> Map.put(:updated_at, DateTime.utc_now)
  end

  @doc """
  Parses shipment data from Kerry Excel file
  """
  def parse(%{
        "consignment_no" => shipment_number,
        "BranchID" => branch_code,
        "sender_name" => sender_name,
        "sender_telephone" => sender_phone,
        "recipient_name" => recipient_name,
        "recipient_telephone" => recipient_phone,
        "recipient_address1" => recipient_address1,
        "recipient_address2" => recipient_address2,
        "recipient_zipcode" => recipient_zip,
      } = data) do
    metadata = Map.drop(data, [
      "consignment_no",
      "BranchID",
      "sender_name",
      "sender_telephone",
      "recipient_name",
      "recipient_telephone",
      "recipient_address1",
      "recipient_address2",
      "recipient_zipcode",
    ])

    %{
      shipment_number: shipment_number,
      branch_code: branch_code,
      sender_name: sender_name,
      sender_phone: sanitize_phone(sender_phone),
      recipient_name: recipient_name,
      recipient_phone: sanitize_phone(recipient_phone),
      recipient_address1: recipient_address1,
      recipient_address2: recipient_address2,
      recipient_zip: "#{recipient_zip}",
      metadata: metadata
    }
  end

  defp sanitize_phone(phone) do
    String.replace(phone, ~r/\D/, "", global: true)
  end
end
