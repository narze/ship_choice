defmodule ShipchoiceDb.Repo.Migrations.RenameSmsMessagesTableToMessage do
  use Ecto.Migration

  def change do
    rename table("sms_messages"), to: table("message")
  end
end
