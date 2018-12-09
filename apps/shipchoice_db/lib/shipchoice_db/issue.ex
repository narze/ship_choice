defmodule ShipchoiceDb.Issue do
  @moduledoc """
  Ecto Schema representing shipments.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias ShipchoiceDb.{Repo, Shipment, Issue}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "issue" do
    field(:shipment_number, :string)
    field(:payer, :string)
    field(:sender, :string)
    field(:route, :string)
    field(:dc, :string)
    field(:last_status_code, :string)
    field(:dly_status_code, :string)
    field(:dly_status_remark, :string)
    field(:station_location, :string)
    field(:metadata, :map)
    field(:resolved_at, :naive_datetime)

    timestamps()
  end

  @doc """
  Validates issue data.

  ## Examples

      iex> changeset(%Issue{}, %{field: value})
      %Issue{}

  """
  def changeset(%Issue{} = issue, attrs) do
    issue
    |> cast(attrs, [
      :shipment_number,
      :payer,
      :sender,
      :route,
      :dc,
      :last_status_code,
      :dly_status_code,
      :dly_status_remark,
      :station_location,
      :metadata,
    ])
    |> validate_required([:shipment_number])
    |> unique_constraint(:shipment_number)
  end

  @doc """
  Get all issues
  """
  def all do
    Repo.all(Issue)
  end

  @doc """
  Retrieves an issue

  ### Examples

      iex> get(1)
      %Issue{}

  """
  def get(id) do
    Repo.get(Issue, id)
  end

  @doc """
  Creates a Issue

  ### Examples

      iex> insert(%{field: value})
      {:ok, %Issue{}}

  """
  def insert(attrs) do
    changeset = Issue.changeset(%Issue{}, attrs)
    Repo.insert(changeset)
  end

  def get_shipment(%Issue{} = issue) do
    from(
      s in Shipment,
      where: s.shipment_number == ^issue.shipment_number
    )
    |> Repo.one()
  end

  def insert_rows(rows) do
    count = Enum.count(rows)

    new =
      rows
      |> Enum.map(fn issue_data ->
        issue = Issue.parse(issue_data)
        case insert(issue) do
          {:ok, _result} -> 1
          _ -> 0
        end
      end)
      |> Enum.sum()

    {:ok, count: count, new: new}
  end

  def parse(
        %{
          consignment_no: shipment_number,
          payer: payer,
          sender: sender,
          route: route,
          dc: dc,
          last_status_code: last_status_code,
          dly_status_code: dly_status_code,
          dly_status_remark: dly_status_remark,
          station_location: station_location,
        } = data
      ) do
    metadata =
      Map.drop(data, [
        :consignment_no,
        :payer,
        :sender,
        :route,
        :dc,
        :last_status_code,
        :dly_status_code,
        :dly_status_remark,
        :station_location,
      ])

    %{
      shipment_number: shipment_number,
      payer: payer,
      sender: sender,
      route: route,
      dc: dc,
      last_status_code: last_status_code,
      dly_status_code: dly_status_code,
      dly_status_remark: dly_status_remark,
      station_location: station_location,
      metadata: metadata,
    }
  end

  def resolved?(issue) do
    !is_nil(issue.resolved_at)
  end
end
