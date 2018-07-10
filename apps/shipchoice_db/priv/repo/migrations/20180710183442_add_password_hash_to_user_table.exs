defmodule ShipchoiceDb.Repo.Migrations.AddPasswordHashToUserTable do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :password_hash, :string
    end
  end
end
