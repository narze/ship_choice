defmodule ShipchoiceDb.SMSMessage do
  @moduledoc """
  Ecto Schema representing SMS messages.
  """
  use Ecto.Schema
  import Ecto.{Changeset}
  alias ShipchoiceDb.{Repo, SMSMessage, Shipment}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sms_messages" do
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

      iex> changeset(%SMSMessage{}, %{field: value})
      %SMSMessage{}

  """
  def changeset(%SMSMessage{} = sms, attrs \\ %{}) do
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
    Repo.all(SMSMessage)
  end

  @doc """
  Retrieves a sms

  ### Examples

      iex> get(1)
      %SMSMessage{}

  """
  def get(id) do
    Repo.get(SMSMessage, id)
  end

  @doc """
  Creates a sms

  ### Examples

      iex> insert(%{field: value})
      {:ok, %SMSMessage{}}

  """
  def insert(attrs) do
    changeset = SMSMessage.changeset(%SMSMessage{}, attrs)
    Repo.insert(changeset)
  end
end
