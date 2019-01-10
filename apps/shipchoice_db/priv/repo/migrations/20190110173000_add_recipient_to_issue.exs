defmodule ShipchoiceDb.Repo.Migrations.AddRecipientToIssue do
  use Ecto.Migration

  def change do
    alter table(:issue) do
      add :recipient, :string
    end
  end
end
