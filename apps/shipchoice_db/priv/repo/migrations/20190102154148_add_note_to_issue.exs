defmodule ShipchoiceDb.Repo.Migrations.AddNoteToIssue do
  use Ecto.Migration

  def change do
    alter table(:issue) do
      add :note, :text
    end
  end
end
