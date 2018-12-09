defmodule ShipchoiceDb.Repo.Migrations.AddResolvedAtToIssue do
  use Ecto.Migration

  def change do
    alter table(:issue) do
      add :resolved_at, :naive_datetime
    end
  end
end
