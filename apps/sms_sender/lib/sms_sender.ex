defmodule SMSSender do
  @moduledoc """
  Documentation for SMSSender.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SMSSender.hello
      :world

  """
  def hello do
    :world
  end

  @doc """
  Send message to specified phone number

  ## Examples

      iex> SMSSender.send_message("Hello", "0812345678")
      {:ok, "Message Sent"}

  """
  def send_message(message, phone_number) do
    {:ok, "Message Sent"}
  end
end
