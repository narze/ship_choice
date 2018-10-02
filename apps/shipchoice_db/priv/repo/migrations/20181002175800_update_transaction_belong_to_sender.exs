defmodule ShipchoiceDb.Repo.Migrations.UpdateTransactionBelongToSender do
  use Ecto.Migration

  def up do
    alter table(:transaction) do
      add :sender_id, references(:sender, type: :uuid)
      remove :user_id
    end
  end

  def down do
    alter table(:transaction) do
      add :user_id, references(:user, type: :uuid)
      remove :sender_id
    end
  end
end
