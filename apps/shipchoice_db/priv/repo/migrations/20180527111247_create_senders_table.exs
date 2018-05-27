defmodule ShipchoiceDb.Repo.Migrations.CreateSendersTable do
  use Ecto.Migration

  def change do
    create table(:sender, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :phone, :string
      timestamps()
    end

    create unique_index(:sender, [:name])
    create unique_index(:sender, [:phone])
  end
end
