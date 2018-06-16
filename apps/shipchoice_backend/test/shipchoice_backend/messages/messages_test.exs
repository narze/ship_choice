defmodule ShipchoiceBackend.MessagesTest do
  use ShipchoiceDb.DataCase

  alias ShipchoiceBackend.Messages

  describe "sms" do
    alias ShipchoiceDb.SMS

    @valid_attrs %{message: "some message", phone: "some phone", sent_at: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{message: "some updated message", phone: "some updated phone", sent_at: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{message: nil, phone: nil, sent_at: nil}

    def sms_fixture(attrs \\ %{}) do
      {:ok, sms} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messages.create_sms()

      sms
    end

    test "list_sms/0 returns all sms" do
      sms = sms_fixture()
      assert Messages.list_sms() == [sms]
    end

    test "get_sms!/1 returns the sms with given id" do
      sms = sms_fixture()
      assert Messages.get_sms!(sms.id) == sms
    end

    test "create_sms/1 with valid data creates a sms" do
      assert {:ok, %SMS{} = sms} = Messages.create_sms(@valid_attrs)
      assert sms.message == "some message"
      assert sms.phone == "some phone"
      assert sms.sent_at == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_sms/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_sms(@invalid_attrs)
    end

    test "update_sms/2 with valid data updates the sms" do
      sms = sms_fixture()
      assert {:ok, sms} = Messages.update_sms(sms, @update_attrs)
      assert %SMS{} = sms
      assert sms.message == "some updated message"
      assert sms.phone == "some updated phone"
      assert sms.sent_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_sms/2 with invalid data returns error changeset" do
      sms = sms_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.update_sms(sms, @invalid_attrs)
      assert sms == Messages.get_sms!(sms.id)
    end

    test "delete_sms/1 deletes the sms" do
      sms = sms_fixture()
      assert {:ok, %SMS{}} = Messages.delete_sms(sms)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_sms!(sms.id) end
    end

    test "change_sms/1 returns a sms changeset" do
      sms = sms_fixture()
      assert %Ecto.Changeset{} = Messages.change_sms(sms)
    end
  end
end
