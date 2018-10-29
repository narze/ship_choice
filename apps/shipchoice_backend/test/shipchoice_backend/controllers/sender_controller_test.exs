defmodule ShipchoiceBackend.SenderControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Credits, Sender, Repo}
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
        get(conn, sender_path(conn, :show, 1)),
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

  setup %{conn: conn} = tags do
    if tags[:login_as] do
      user = insert(:admin_user, username: tags[:login_as])
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      {:ok, conn: conn}
    end
  end

  describe "with a signed in user" do
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
      sender = insert(:sender, name: "Foo", phone: "0863949474")
      Credits.add_credit_to_sender(100, sender)

      _shipment1 = insert(:shipment, shipment_number: "PORM000188508", sender_phone: sender.phone)
      _shipment2 = insert(:shipment, shipment_number: "PORM000188509", sender_phone: sender.phone)

      with_mock Messages, send_message_to_all_shipments_in_sender: fn _sender, 100 -> {:ok, "Sent", 2} end do
        conn = post(conn, "/senders/#{sender.id}/send_message_to_shipments")

        assert redirected_to(conn) == "/senders"
        assert get_flash(conn, :info) =~ "Sent message to 2 shipments."
        assert called(Messages.send_message_to_all_shipments_in_sender(:_, 100))
      end

      assert Credits.get_sender_credit(sender) == 100 -2
    end

    @tag login_as: "narze"
    test "POST /senders/:id/send_message_to_shipments, when having insufficient credits", %{conn: conn} do
      sender = insert(:sender, name: "Foo", phone: "0863949474")

      _shipment1 = insert(:shipment, shipment_number: "PORM000188508", sender_phone: sender.phone)
      _shipment2 = insert(:shipment, shipment_number: "PORM000188509", sender_phone: sender.phone)

      with_mock Messages, send_message_to_all_shipments_in_sender: fn _sender -> {:ok, "Sent", 2} end do
        conn = post(conn, "/senders/#{sender.id}/send_message_to_shipments")

        assert redirected_to(conn) == "/senders"
        assert get_flash(conn, :error) =~ "Messages not sent. Insufficient credit."
        refute called(Messages.send_message_to_all_shipments_in_sender(:_))
      end

      assert Credits.get_sender_credit(sender) == 0
    end

    @tag login_as: "narze"
    test "POST /senders/:id/send_message_to_shipments, when having partial credits", %{conn: conn} do
      sender = insert(:sender, name: "Foo", phone: "0863949474")
      Credits.add_credit_to_sender(1, sender)

      _shipment1 = insert(:shipment, shipment_number: "PORM000188508", sender_phone: sender.phone)
      _shipment2 = insert(:shipment, shipment_number: "PORM000188509", sender_phone: sender.phone)

      with_mock Messages, send_message_to_all_shipments_in_sender: fn _sender, _limit -> {:ok, "Sent", 1} end do
        conn = post(conn, "/senders/#{sender.id}/send_message_to_shipments")

        assert redirected_to(conn) == "/senders"
        assert get_flash(conn, :info) =~ "Sent message to 1 shipments."
        assert called(Messages.send_message_to_all_shipments_in_sender(:_, 1))
      end

      assert Credits.get_sender_credit(sender) == 0
    end
  end

  describe "GET /senders/:id" do
    @tag login_as: "narze"
    test "renders sender dashboard", %{conn: conn, user: user} do
      sender = insert(:sender, users: [user])
      shipments = insert_list(2, :shipment, sender_phone: sender.phone)
      conn = get(conn, "/senders/#{sender.id}")

      assert html_response(conn, 200) =~ sender.name
      assert html_response(conn, 200) =~ "Total Shipments"
      assert html_response(conn, 200) =~ sender |> Sender.count_shipments() |> Integer.to_string()
      assert html_response(conn, 200) =~ "Remaining Credits"
      assert html_response(conn, 200) =~ sender |> Credits.get_sender_credit() |> Integer.to_string()
      assert html_response(conn, 200) =~ shipments |> Enum.at(0) |> Map.get(:shipment_number)
      assert html_response(conn, 200) =~ shipments |> Enum.at(1) |> Map.get(:shipment_number)
    end
  end
end
