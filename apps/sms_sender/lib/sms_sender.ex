defmodule SMSSender do
  @sms_sender_impl Application.fetch_env!(:sms_sender, :sender)
  @moduledoc """
  Documentation for SMSSender.
  """

  @doc """
  Send message to specified phone number
  """
  def send_message(message, phone_number) do
    @sms_sender_impl.send_message(message, phone_number)
  end
end
