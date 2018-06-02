defmodule SMSSenderTest do
  use ExUnit.Case
  doctest SMSSender

  test "greets the world" do
    assert SMSSender.hello() == :world
  end
end
