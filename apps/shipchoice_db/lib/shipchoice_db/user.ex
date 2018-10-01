defmodule ShipchoiceDb.User do
  @moduledoc """
  Ecto Schema representing users
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias ShipchoiceDb.{Repo, Sender, Transaction, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :is_admin, :boolean

    timestamps()

    has_many :transactions, Transaction
    many_to_many :senders, Sender, join_through: "sender_user"
  end

  @required_fields ~w(name username password)a
  @optional_fields ~w(is_admin)a

  @doc """
  Validates user data.

  ## Examples

      iex> changeset(%User{}, %{field: value})
      %User{}

  """
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(
          changeset,
          :password_hash,
          Comeonin.Bcrypt.hashpwsalt(pass)
        )
      _ ->
        changeset
    end
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

  def authenticate(username, password) do
    user = get_by_username(username)

    cond do
      user && Comeonin.Bcrypt.checkpw(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, :not_found}
    end
  end

  def get_by_username(username) do
    from(u in User, where: u.username == ^username)
    |> Repo.one()
  end

  def search(query, ""), do: query
  def search(query, search_term) do
    wildcard = "%#{search_term}%"

    from sender in query,
      where: ilike(sender.name, ^wildcard),
      or_where: ilike(sender.username, ^wildcard)
  end
end
