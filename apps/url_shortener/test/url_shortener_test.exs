defmodule URLShortenerTest do
  use ExUnit.Case
  doctest URLShortener

  test "greets the world" do
    assert URLShortener.hello() == :world
  end
end
