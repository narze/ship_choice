defmodule ShipchoiceDb.MembershipTest do
  use ExUnit.Case

  alias ShipchoiceDb.{Membership, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  @valid_attrs %{
    sender_name: "Shopuu",
    sender_phone: "0812345678",
    name: "John Doe",
    username: "john",
    password: "password"
  }

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "changeset/1" do
    test "changeset with valid attributes" do
      changeset = Membership.changeset(%Membership{}, @valid_attrs)
      assert changeset.valid?
    end
  end

  describe "insert/1" do
    test "creates sender with associated user with valid password" do
      changeset = Membership.changeset(%Membership{}, @valid_attrs)

      {:ok, result} = Membership.insert(changeset)

      assert result.sender.id != nil
      assert result.user.id != nil
      assert result.sender_user.id != nil
    end
  end
end
