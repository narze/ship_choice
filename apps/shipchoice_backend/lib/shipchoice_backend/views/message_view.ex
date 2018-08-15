defmodule ShipchoiceBackend.MessageView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.Message

  def sent_at(%Message{} = message) do
    if message.sent_at do
      message.sent_at |> Timex.format!("{relative}", :relative)
    end
  end

  def shipment_number(%Message{} = message) do
    if message.shipment do
      message.shipment.shipment_number
    end
  end
end
