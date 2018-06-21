defmodule ShipchoiceBackend.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias ShipchoiceDb.{Repo, SMS, Shipment}

  @doc """
  Returns the list of sms.

  ## Examples

      iex> list_sms()
      [%SMS{}, ...]

  """
  def list_sms do
    Repo.all(SMS)
  end

  @doc """
  Gets a single sms.

  Raises `Ecto.NoResultsError` if the Sms does not exist.

  ## Examples

      iex> get_sms!(123)
      %SMS{}

      iex> get_sms!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sms!(id), do: Repo.get!(SMS, id)

  @doc """
  Creates a sms.

  ## Examples

      iex> create_sms(%{field: value})
      {:ok, %SMS{}}

      iex> create_sms(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sms(attrs \\ %{}) do
    %SMS{}
    |> SMS.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sms.

  ## Examples

      iex> update_sms(sms, %{field: new_value})
      {:ok, %SMS{}}

      iex> update_sms(sms, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sms(%SMS{} = sms, attrs) do
    sms
    |> SMS.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SMS.

  ## Examples

      iex> delete_sms(sms)
      {:ok, %SMS{}}

      iex> delete_sms(sms)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sms(%SMS{} = sms) do
    Repo.delete(sms)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sms changes.

  ## Examples

      iex> change_sms(sms)
      %Ecto.Changeset{source: %SMS{}}

  """
  def change_sms(%SMS{} = sms) do
    SMS.changeset(sms, %{})
  end

  @doc """
  Creates a SMS & send the message to shipment recipient
  """
  def send_message_to_shipment(message, %Shipment{} = shipment) do
    attrs = %{
      message: message
    }

    existing_sms = Ecto.assoc(shipment, :sms)

    if Repo.aggregate(existing_sms, :count, :id) > 0 do
      {:error, "Message already sent for this shipment"}
    else
      sms = shipment
      |> Ecto.build_assoc(:sms, attrs)
      |> Repo.insert!()

      # TODO: Use the sms to send message
      {:ok, _response} = SMSSender.send_message(sms.message, "+66814879292")

      {:ok, sms}
    end
  end
end
