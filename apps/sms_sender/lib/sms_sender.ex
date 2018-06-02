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
  Send message to specified phone number using Apitel
  """
  def send_message(message, phone_number) do
    api_key = Application.fetch_env!(:sms_sender, :apitel_api_key)
    api_secret = Application.fetch_env!(:sms_sender, :apitel_api_secret)
    sender_id = Application.fetch_env!(:sms_sender, :apitel_sender_id)

    case HTTPoison.post(
      "https://api.apitel.co/sms",
      "{
        \"to\": \"#{phone_number}\",
        \"from\": \"#{sender_id}\",
        \"text\": \"#{message}\",
        \"apiKey\": \"#{api_key}\",
        \"apiSecret\": \"#{api_secret}\"
      }",
      [{"Content-Type", "application/json"}]
    ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
        {:error, "Not found"}
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.puts "Unknown error"
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        {:error, reason}
    end
  end
end
