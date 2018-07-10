defmodule ShipchoiceDb.User do
  @moduledoc """
  Ecto Schema representing users
  """
  use Ecto.Schema
  import Ecto.{Changeset}
  alias ShipchoiceDb.{Repo, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user" do
    field :name, :string
    field :username, :string

    timestamps()
  end

  @doc """
  Validates user data.

  ## Examples

      iex> changeset(%User{}, %{field: value})
      %User{}

  """
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :name,
      :username,
    ])
    |> validate_required([:name, :username])
  end

  @doc """
  Get all users
  """
  def all do
    Repo.all(User)
  end

  @doc """
  Retrieves a user

  ### Examples

      iex> get(1)
      %User{}

  """
  def get(id) do
    Repo.get(User, id)
  end

  @doc """
  Creates a user

  ### Examples

      iex> insert(%{field: value})
      {:ok, %User{}}

  """
  def insert(attrs) do
    changeset = User.changeset(%User{}, attrs)
    Repo.insert(changeset)
  end
end
