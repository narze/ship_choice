defmodule ApitelMockTest do
  use ExUnit.Case

  describe "send_message/2" do
    test "returns success : message sent" do
      assert {:ok, _} = SMSSender.ApitelMock.send_message("Hello from ShypChoice", "+66863949474")
    end
  end
end
