defmodule ShipchoiceBackend.SenderView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.{Credits, Sender}

  def get_credits(%Sender{} = sender) do
    Credits.get_sender_credit(sender)
  end
end
