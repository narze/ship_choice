defmodule ShipchoiceDb.Factory do
  use ExMachina.Ecto, repo: ShipchoiceDb.Repo

  alias ShipchoiceDb.{Sender, Shipment, Message, User}

  def sender_factory do
    %Sender{
      name: "Manassarn Manoonchai",
      phone: "0863949474",
    }
  end

  def shipment_factory do
    %Shipment{
      shipment_number: "PORM000188508",
      branch_code: "PORM",
      sender_name: "Manassarn Manoonchai",
      sender_phone: "0863949474",
      recipient_name: "John Doe",
      recipient_phone: "0812345678",
      recipient_address1: "345, Sixth Avenue",
      recipient_address2: "District 51",
      recipient_zip: "12345",
      metadata: %{
        "service_code" => "ND",
        "weight" => 1.06,
      }
    }
  end

  def message_factory do
    %Message{
      status: "pending",
      message: "Hello",
      phone: "0812345678",
    }
  end

  def user_factory do
    %User{
      name: "Manassarn Manoonchai",
      username: "narze",
      password: "password",
      is_admin: true,
    }
  end
end
