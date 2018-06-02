defmodule ShipchoiceDb.Repo.Migrations.CreateSMSMessagesTable do
  use Ecto.Migration

  def change do
    create table(:sms_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :message, :string
      add :phone, :string
      add :sent_at, :naive_datetime
      add :shipment_id, references(:shipment, type: :uuid)

      timestamps()
    end
  end
end
