defmodule SMSSenderTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest SMSSender

  setup do
    HTTPoison.start
  end

  describe "send_message/2" do
    # context "send with wrong format of phone number (no +66)" do
      test "returns error : invalid number" do
        use_cassette "send_message_error" do
          assert {:error, _} = SMSSender.send_message("Hello from ShypChoice", "0863949474")
        end
      end
    # end

    # context "send with bad authentication" do
      test "returns error : authentication failed" do
        use_cassette "send_message_error_authentication" do
          assert {:error, _} = SMSSender.send_message("Hello from ShypChoice", "+66863949474")
        end
      end
    # end

    # context "send with valid authentication" do
      test "returns success : message sent" do
        use_cassette "send_message_success" do
          assert {:ok, _} = SMSSender.send_message("Hello from ShypChoice", "+66863949474")
        end
      end
    # end
  end
end
