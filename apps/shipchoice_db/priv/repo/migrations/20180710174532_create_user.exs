defmodule ShipchoiceDb.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :username, :string, null: false

      timestamps()
    end
  end
end
