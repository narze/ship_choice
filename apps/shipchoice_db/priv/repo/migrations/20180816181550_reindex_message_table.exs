defmodule ShipchoiceDb.Repo.Migrations.ReindexMessageTable do
  use Ecto.Migration

  def up do
    # Rename primary key
    execute "ALTER TABLE message RENAME CONSTRAINT sms_messages_pkey TO message_pkey;"

    # Add new constraint
    alter table(:message) do
      modify :shipment_id, references(:shipment, type: :uuid, name: "message_shipment_id_fkey")
    end

    # Remove old constraint
    drop constraint(:message, "sms_messages_shipment_id_fkey")
  end

  def down do
    # Rename primary key
    execute "ALTER TABLE message RENAME CONSTRAINT message_pkey TO sms_messages_pkey;"

    # Add new constraint
    alter table(:message) do
      modify :shipment_id, references(:shipment, type: :uuid, name: "sms_messages_shipment_id_fkey")
    end

    # Remove old constraint
    drop constraint(:message, "message_shipment_id_fkey")
  end
end
