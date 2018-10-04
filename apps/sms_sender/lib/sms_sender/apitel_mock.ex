defmodule SMSSender.ApitelMock do
  def send_message(_message, _phone_number) do
    {:ok, %{
      "id" => 13,
      "from" => "ATSMS",
      "to" => "+661234567890",
      "text" => "Good evening.",
      "status" => "ACCEPTED"
    }}
  end
end
