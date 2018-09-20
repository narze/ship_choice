defmodule ShipchoiceDb.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transaction, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:user, type: :uuid)
      add :amount, :integer, null: false
      add :balance, :integer, null: false

      timestamps()
    end
  end
end
