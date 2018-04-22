defmodule Db.Repo.Migrations.CreateShipmentsTable do
  use Ecto.Migration

  def change do
    create table(:shipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :shipment_number, :string, null: false
      add :branch_code, :string
      add :sender_name, :string
      add :sender_phone, :string
      add :recipient_name, :string
      add :recipient_phone, :string
      add :recipient_address1, :string
      add :recipient_address2, :string
      add :recipient_zip, :string
      add :metadata, :map
      timestamps()
    end

    create unique_index(:shipment, [:shipment_number])
  end
end
