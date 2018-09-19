defmodule ShipchoiceDb.Factory do
  use ExMachina.Ecto, repo: ShipchoiceDb.Repo

  alias ShipchoiceDb.{Sender, Shipment, Message, User}

  def sender_factory do
    %Sender{
      name: Faker.Name.name(),
      phone: Faker.Phone.EnUs.phone(),
    }
  end

  def shipment_factory do
    %Shipment{
      shipment_number: "PORM" <> (Faker.random_between(0, 30000000) |> to_string),
      branch_code: "PORM",
      sender_name: Faker.Name.name(),
      sender_phone: Faker.Phone.EnUs.phone(),
      recipient_name: Faker.Name.name(),
      recipient_phone: Faker.Phone.EnUs.phone(),
      recipient_address1: Faker.Address.street_address(),
      recipient_address2: Faker.Address.state(),
      recipient_zip: Faker.Address.zip_code(),
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
      phone: Faker.Phone.EnUs.phone(),
    }
  end

  def admin_user_factory do
    %User{
      name: Faker.Name.name(),
      username: "admin",
      password: "password",
      is_admin: true,
    }
  end

  def user_factory do
    %User{
      name: Faker.Name.name(),
      username: "sender",
      password: "password",
      is_admin: false,
    }
  end
end
