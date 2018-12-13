defmodule ShipchoiceDb.Repo.Migrations.CreateIssueTable do
  use Ecto.Migration

  def change do
    create table(:issue, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :shipment_number, :string, null: false
      add :payer, :string
      add :sender, :string
      add :route, :string
      add :dc, :string
      add :last_status_code, :string
      add :dly_status_code, :string
      add :dly_status_remark, :string
      add :station_location, :string
      add :metadata, :map
      timestamps()
    end

    create unique_index(:issue, [:shipment_number])
  end
end
