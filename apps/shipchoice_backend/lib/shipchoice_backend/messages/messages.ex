defmodule ShipchoiceBackend.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias ShipchoiceDb.{Repo, Message, Shipment, Sender}

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_message()
      [%Message{}, ...]

  """
  def list_message do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  @doc """
  Creates a message & send the message to shipment recipient
  """
  def send_message_to_shipment(message, %Shipment{} = shipment) do
    send_message_to_shipment(message, shipment, resend: false)
  end

  def send_message_to_shipment(message, %Shipment{} = shipment, [resend: resend]) do
    attrs = %{
      message: message
    }

    existing_message = Ecto.assoc(shipment, :messages)

    if !resend && Repo.aggregate(existing_message, :count, :id) > 0 do
      {:error, "Message already sent for this shipment"}
    else
      message = shipment
      |> Ecto.build_assoc(:messages, attrs)
      |> Repo.insert!()

      # TODO: Use the message to send message
      {:ok, _response} =
        SMSSender.send_message(
          message.message,
          transform_phone_number(shipment.recipient_phone)
        )

      {:ok, message}
    end
  end

  @doc """
  Send multiple Message to all shipments in a sender
  """
  def send_message_to_all_shipments_in_sender(%Sender{} = sender) do
    shipments = Sender.get_shipments(sender)

    messages_sent_count = shipments
    |> Enum.map(fn(shipment) -> send_message_to_shipment(build_shipment_message(shipment), shipment) end)
    |> Enum.count(fn({result, _}) -> result == :ok end)

    {:ok, "Sent to #{messages_sent_count} shipments"}
  end

  def transform_phone_number(phone_number) do
    phone_number
    |> String.replace_prefix("0", "+66")
  end

  def build_shipment_message(shipment) do
    "สินค้ากำลังนำส่งโดย Kerry Express ติดตามสถานะจาก https://shypchoice.com/t/#{shipment.shipment_number}"
  end
end
