defmodule ShipchoiceBackend.SenderView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.{Credits, Sender, Shipment}

  def get_credits(%Sender{} = sender) do
    Credits.get_sender_credit(sender)
  end

  def is_message_sent(%Shipment{} = shipment) do
    Shipment.has_sent_message(shipment)
  end
end
