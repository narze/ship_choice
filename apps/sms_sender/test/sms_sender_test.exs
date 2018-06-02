defmodule SMSSenderTest do
  use ExUnit.Case
  doctest SMSSender

  test "greets the world" do
    assert SMSSender.hello() == :world
  end

  describe "send_message/2" do
    test "sends message to phone number" do
      assert {:ok, _} = SMSSender.send_message("Hello from ShypChoice", "0863949474")
    end
  end
end
