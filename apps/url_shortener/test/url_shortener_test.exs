defmodule URLShortenerTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest URLShortener

  setup do
    HTTPoison.start()
  end

  describe "shorten_url/1" do
    test "returns shortened url" do
      use_cassette "bitly_shorten_url" do
        assert {:ok, _} = URLShortener.shorten_url("https://shypchoice.com")
      end
    end

    test "returns error when bit.ly returns error" do
      use_cassette "bitly_shorten_url_error" do
        assert {:error, "Url shorten failed"} = URLShortener.shorten_url("https://shypchoice.com")
      end
    end
  end
end
