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
      {:ok, inserted_user} = User.insert(params_for(:user))

      user = User.get(inserted_user.id)

      assert user.id == inserted_user.id
      assert user.name == inserted_user.name
      assert user.username == inserted_user.username
      assert user.password == nil
      assert user.password_hash != nil
    end
  end
end
