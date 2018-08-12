defmodule URLShortener do
  @moduledoc """
  Documentation for URLShortener.
  """

  @doc """
  Shortens URL using bit.ly
  """
  def shorten_url(url) do
    access_token = Application.fetch_env!(:url_shortener, :bitly_access_token)
    group_guid = Application.fetch_env!(:url_shortener, :bitly_group_guid)

    case HTTPoison.post("https://api-ssl.bitly.com/v4/shorten", "{
        \"group_guid\": \"#{group_guid}\",
        \"domain\": \"bit.ly\",
        \"long_url\": \"#{url}\"
      }", [
           {"Host", "api-ssl.bitly.com"},
           {"Authorization", "Bearer #{access_token}"},
           {"Content-Type", "application/json"}
         ]) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code == 200 or status_code == 201 ->
        IO.puts(body)
        json_body = Poison.Parser.parse!(body)
        {:ok, json_body["id"]}

      {:ok, %HTTPoison.Response{body: body}} ->
        IO.puts(body)
        {:error, "Url shorten failed"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        {:error, "Url shorten failed"}
    end
  end
end
