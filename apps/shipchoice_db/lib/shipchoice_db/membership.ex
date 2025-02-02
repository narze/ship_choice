defmodule ShipchoiceDb.Membership do
  @moduledoc """
  Ecto Embedded Schema representing memberships
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ShipchoiceDb.{Membership, Repo, Sender, User}

  embedded_schema do
    field :sender_name, :string
    field :sender_phone, :string
    field :name, :string
    field :username, :string
    field :password, :string
  end

  @required_fields ~w(sender_name sender_phone name username password)a

  @doc """
  Validates membership data.

  ## Examples

      iex> changeset(%Membership{}, %{field: value})
      %Membership{}

  """
  def changeset(%Membership{} = membership, attrs \\ %{}) do
    membership
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def insert(%Ecto.Changeset{} = changeset) do
    changeset.params
    |> to_multi()
    |> Repo.transaction()
  end

  def insert(attrs) do
    changeset = Membership.changeset(%Membership{}, attrs)
    insert(changeset)
  end

  defp to_multi(params) do
    Ecto.Multi.new
    |> Ecto.Multi.insert(:sender, sender_changeset(params))
    |> Ecto.Multi.insert(:user, user_changeset(params))
    |> Ecto.Multi.run(:sender_user, fn _, changes ->
      sender = changes.sender
      user = changes.user

      user
      |> Repo.preload(:senders)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:senders, [sender])
      |> Repo.update()
    end)
  end

  defp sender_changeset(%{"sender_name" => name, "sender_phone" => phone}) do
    Sender.changeset %Sender{name: name, phone: phone}
  end

  defp user_changeset(params) do
    user_params = Map.take(params, ["name", "username", "password"])
    User.changeset %User{}, user_params
  end
end
