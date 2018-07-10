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
      inserted_user = insert(:user)

      user = User.get(inserted_user.id)

      assert user.id == inserted_user.id
      assert user.name == inserted_user.name
      assert user.username == inserted_user.username
    end
  end
end
