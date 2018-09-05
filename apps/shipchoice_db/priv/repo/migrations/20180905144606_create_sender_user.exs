defmodule ShipchoiceDb.Repo.Migrations.CreateSenderUser do
  use Ecto.Migration

  def change do
    create table(:sender_user) do
      add :sender_id, references(:sender, type: :uuid)
      add :user_id, references(:user, type: :uuid)
    end

    create unique_index(:sender_user, [:sender_id, :user_id])
  end
end
