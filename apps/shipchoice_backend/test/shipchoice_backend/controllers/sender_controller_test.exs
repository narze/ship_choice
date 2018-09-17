defmodule ShipchoiceBackend.SenderControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Sender, Repo}
  alias ShipchoiceBackend.Messages

  import Mock
  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, sender_path(conn, :index)),
        get(conn, sender_path(conn, :new)),
        post(conn, sender_path(conn, :create), %{"sender" => %{}})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "with a signed in user" do
    setup %{conn: conn, login_as: username} do
      user = insert(:admin_user, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "narze"
    test "GET /senders", %{conn: conn} do
      conn = get(conn, "/senders")
      assert html_response(conn, 200) =~ "All Senders"
      assert html_response(conn, 200) =~ "Add New Sender"
    end

    @tag login_as: "narze"
    test "GET /senders with existing senders", %{conn: conn} do
      senders = [
        %{name: "Foo", phone: "0812345678"},
        %{name: "Bar", phone: "0898765432"}
      ]

      senders
      |> Enum.each(fn sender -> Sender.insert(sender) end)

      conn = get(conn, "/senders")

      assert html_response(conn, 200) =~ "Foo"
      assert html_response(conn, 200) =~ "0812345678"
      assert html_response(conn, 200) =~ "Bar"
      assert html_response(conn, 200) =~ "0898765432"
    end

    @tag login_as: "narze"
    test "GET /senders with search term", %{conn: conn} do
      senders = [
        %{name: "Foo", phone: "0812345678"},
        %{name: "Bar", phone: "0898765432"}
      ]

      senders
      |> Enum.each(fn sender -> Sender.insert(sender) end)

      conn = get(conn, "/senders?search=8123456")

      assert html_response(conn, 200) =~ "Foo"
      assert html_response(conn, 200) =~ "0812345678"
      refute html_response(conn, 200) =~ "Bar"
      refute html_response(conn, 200) =~ "0898765432"
    end

    @tag login_as: "narze"
    test "GET /senders/new", %{conn: conn} do
      conn = get(conn, "/senders/new")

      assert html_response(conn, 200) =~ "Add New Sender"
    end

    @tag login_as: "narze"
    test "POST /senders", %{conn: conn} do
      conn =
        post(conn, "/senders", %{
          sender: %{
            name: "Foo",
            phone: "0812345678"
          }
        })

      assert redirected_to(conn) == "/senders"
      assert get_flash(conn, :info) =~ "Added New Sender."

      assert length(Sender.all()) == 1
    end

    @tag login_as: "narze"
    test "POST /senders/:id/send_message_to_shipments", %{conn: conn} do
      sender = %{name: "Foo", phone: "0863949474"}

      {:ok, sender} = Sender.insert(sender)

      _shipment1 = insert(:shipment, %{shipment_number: "PORM000188508"})
      _shipment2 = insert(:shipment, %{shipment_number: "PORM000188509"})

      with_mock Messages, send_message_to_all_shipments_in_sender: fn _sender -> {:ok, "Sent"} end do
        conn = post(conn, "/senders/#{sender.id}/send_message_to_shipments")

        assert redirected_to(conn) == "/senders"
        assert get_flash(conn, :info) =~ "Sent message to 2 shipments."
        assert called(Messages.send_message_to_all_shipments_in_sender(:_))
      end
    end
  end
end
