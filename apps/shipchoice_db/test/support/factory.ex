defmodule ShipchoiceDb.Factory do
  use ExMachina.Ecto, repo: ShipchoiceDb.Repo

  alias ShipchoiceDb.{Issue, Message, Sender, Shipment, Transaction, User}

  def issue_factory do
    %Issue{
      shipment_number: "PORM" <> (Faker.random_between(0, 30000000) |> to_string),
      payer: Faker.Name.name(),
      sender: Faker.Name.name(),
      recipient: Faker.Name.name(),
      route: "ABCXYZ",
      dc: "BKKXYZ",
      last_status_code: "CLS",
      dly_status_code: "DLY06",
      dly_status_remark: "Cancelled",
      station_location: "ABCDEF",
    }
  end

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

  def transaction_factory do
    %Transaction{
      amount: Faker.random_between(-10000, 10000),
      balance: Faker.random_between(-10000, 10000),
      sender: sender_factory(),
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
