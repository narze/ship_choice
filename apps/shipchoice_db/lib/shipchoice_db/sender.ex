defmodule ShipchoiceDb.Sender do
  @moduledoc """
  Ecto Schema representing senders.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ShipchoiceDb.{Repo, Sender}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sender" do
    field :name, :string
    field :phone, :string

    timestamps()
  end

  @doc """
  Validates sender data.

  ## Examples

      iex> changeset(%Sender{}, %{field: value})
      %Sender{}

  """
  def changeset(%Sender{} = sender, attrs) do
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
end
