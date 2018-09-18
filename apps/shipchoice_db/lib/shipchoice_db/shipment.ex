defmodule ShipchoiceDb.Shipment do
  @moduledoc """
  Ecto Schema representing shipments.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias ShipchoiceDb.{Repo, Shipment, Message}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "shipment" do
    field(:shipment_number, :string)
    field(:branch_code, :string)
    field(:sender_name, :string)
    field(:sender_phone, :string)
    field(:recipient_name, :string)
    field(:recipient_phone, :string)
    field(:recipient_address1, :string)
    field(:recipient_address2, :string)
    field(:recipient_zip, :string)
    field(:metadata, :map)
    has_many(:messages, Message)

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
      :metadata
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
  Inserts list of shipments, skipping existing shipments
  """
  def insert_only_new_shipments(shipment_list) do
    count = Enum.count(shipment_list)

    new =
      shipment_list
      |> Enum.map(fn shipment ->
        case insert(shipment) do
          {:ok, result} -> 1
          _ -> 0
        end
      end)
      |> Enum.sum()

    {:ok, count: count, new: new}
  end

  defp add_timestamps(row) do
    row
    |> Map.put(:inserted_at, DateTime.utc_now())
    |> Map.put(:updated_at, DateTime.utc_now())
  end

  @doc """
  Parses shipment data from Kerry Excel file
  """
  def parse(
        %{
          "consignment_no" => shipment_number,
          "BranchID" => branch_code,
          "sender_name" => sender_name,
          "sender_telephone" => sender_phone,
          "recipient_name" => recipient_name,
          "recipient_telephone" => recipient_phone,
          "recipient_address1" => recipient_address1,
          "recipient_address2" => recipient_address2,
          "recipient_zipcode" => recipient_zip
        } = data
      ) do
    metadata =
      Map.drop(data, [
        "consignment_no",
        "BranchID",
        "sender_name",
        "sender_telephone",
        "recipient_name",
        "recipient_telephone",
        "recipient_address1",
        "recipient_address2",
        "recipient_zipcode"
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

  def sanitize_phone(phone) do
    captured =
      Regex.scan(~r/\d{10}/, phone, capture: :first)
      |> List.first()

    if is_list(captured) do
      captured |> List.first()
    end
  end

  def tracking_url(%Shipment{} = shipment) do
    "http://shypchoice.com/t/#{shipment.shipment_number}"
  end

  def search(query, ""), do: query
  def search(query, search_term) do
    wildcard = "%#{search_term}%"

    from(
      shipment in query,
      where: ilike(shipment.shipment_number, ^wildcard),
      or_where: ilike(shipment.sender_name, ^wildcard),
      or_where: ilike(shipment.sender_phone, ^wildcard),
      or_where: ilike(shipment.recipient_name, ^wildcard),
      or_where: ilike(shipment.recipient_phone, ^wildcard)
    )
  end

  def from_senders(query, senders) do
    sender_phones = Enum.map(senders, &(&1.phone))
    from(
      shipment in query,
      where: shipment.sender_phone in ^sender_phones
    )
  end
end
