defmodule ShipchoiceDb.UserTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{User, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "factory" do
    test "factory is valid" do
      {:ok, inserted_user} = User.insert(params_for(:admin_user))
      {:error, _} = User.insert(params_for(:admin_user))

      user = User.get(inserted_user.id)

      assert user.id == inserted_user.id
      assert user.name == inserted_user.name
      assert user.username == inserted_user.username
      assert user.password == nil
      assert user.password_hash != nil
      assert user.is_admin == true
    end
  end

  test "authenticate/1" do
    {:ok, _user} = User.insert(params_for(:user, username: "username", password: "password"))
    assert {:ok, %User{}} = User.authenticate("username", "password")
  end

  describe "search/2" do
    test "returns results matched by user name" do
      user = insert(:admin_user)

      result =
        User
        |> User.search(user.name |> String.slice(1..-2))
        |> Repo.all()

      assert result == [user |> Map.put(:password, nil) |> Map.put(:is_admin, true)]
    end

    test "returns results matched by username" do
      user = insert(:admin_user)

      result =
        User
        |> User.search(user.username |> String.slice(1..-2))
        |> Repo.all()

      assert result == [user |> Map.put(:password, nil) |> Map.put(:is_admin, true)]
    end
  end

  describe "user" do
    test "has many senders" do
      inserted_user = insert(:admin_user, senders: [build(:sender)])

      user =
        User.get(inserted_user.id)
        |> Repo.preload(:senders)

      assert length(user.senders) == 1
    end
  end
end
