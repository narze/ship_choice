defmodule ShipchoiceBackend.ShipmentControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Credits, Message, Repo, Shipment}

  import Mock
  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, shipment_path(conn, :index)),
        get(conn, shipment_path(conn, :upload)),
        get(conn, shipment_path(conn, :upload_pending)),
        post(conn, shipment_path(conn, :do_upload)),
        post(conn, shipment_path(conn, :do_upload_pending)),
        post(conn, shipment_path(conn, :send_message, 1))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "with a signed in admin user" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "admin", admin: true
    test "GET /shipments", %{conn: conn} do
      conn = get(conn, "/shipments")
      assert html_response(conn, 200) =~ "All Shipments"
      assert html_response(conn, 200) =~ "Upload Kerry Report"
      assert html_response(conn, 200) =~ "Upload Kerry Pending Report"
    end

    @tag login_as: "user"
    test "GET /shipments with non admin", %{conn: conn} do
      conn = get(conn, "/shipments")
      assert html_response(conn, 200) =~ "All Shipments"
      refute html_response(conn, 200) =~ "Upload Kerry Report"
      refute html_response(conn, 200) =~ "Upload Kerry Pending Report"
    end

    @tag login_as: "admin", admin: true
    test "GET /shipments with existing shipments", %{conn: conn} do
      shipments = [
        %{shipment_number: "SHP0001"},
        %{shipment_number: "SHP0002"}
      ]

      shipments
      |> Enum.each(fn shipment -> Shipment.insert(shipment) end)

      conn = get(conn, "/shipments")

      assert html_response(conn, 200) =~ "SHP0001"
      assert html_response(conn, 200) =~ "SHP0002"
    end

    @tag login_as: "user"
    test "GET /shipments with existing shipments with non admin user", %{conn: conn, user: user} do
      sender = insert(:sender, phone: "0876543210", users: [user])

      shipments = [
        %{shipment_number: "SHP0001", sender_phone: "0876543210"},
        %{shipment_number: "SHP0002"}
      ]

      shipments
      |> Enum.each(fn shipment -> Shipment.insert(shipment) end)

      conn = get(conn, "/shipments")

      assert html_response(conn, 200) =~ "SHP0001"
      refute html_response(conn, 200) =~ "SHP0002"
    end

    @tag login_as: "admin", admin: true
    test "GET /shipments with search term", %{conn: conn} do
      shipments = [
        %{shipment_number: "SHP0001"},
        %{shipment_number: "SHP0002"}
      ]

      shipments
      |> Enum.each(fn shipment -> Shipment.insert(shipment) end)

      conn = get(conn, "/shipments?search=HP0001")

      assert html_response(conn, 200) =~ "SHP0001"
      refute html_response(conn, 200) =~ "SHP0002"
    end

    @tag login_as: "user"
    test "GET /shipments/upload with non admin user", %{conn: conn} do
      conn = get(conn, "/shipments/upload")
      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "GET /shipments/upload", %{conn: conn} do
      conn = get(conn, "/shipments/upload")
      assert html_response(conn, 200) =~ "Upload Kerry Report"
    end

    @tag login_as: "user"
    test "POST /shipments/upload with non admin user", %{conn: conn} do
      conn = post(conn, "/shipments/upload")
      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "POST /shipments/upload", %{conn: conn} do
      conn = post(conn, "/shipments/upload")
      assert redirected_to(conn) == "/shipments/upload"
      assert get_flash(conn, :error) == "Kerry Report File Needed"
    end

    @tag login_as: "admin", admin: true
    test "POST /shipments/upload with xlsx file", %{conn: conn} do
      upload = %Plug.Upload{
        path: "test/fixtures/kerry.xlsx",
        filename: "kerry.xlsx"
      }

      conn = post(conn, "/shipments/upload", %{kerry_report: upload})

      assert redirected_to(conn) == "/shipments"
      assert get_flash(conn, :info) =~ "Uploaded Kerry Report."
      assert get_flash(conn, :info) =~ "13 Rows Processed. 13 Shipments Added."

      assert length(Shipment.all()) == 13

      # Recycle & manually assign current_user
      saved_assigns = conn.assigns

      conn =
        conn
        |> recycle()
        |> Map.put(:assigns, saved_assigns)

      # Add message into a shipment
      shipment = Shipment |> Ecto.Query.first() |> Repo.one()
      insert(:message, shipment_id: shipment.id)

      # Upload again
      conn2 = post(conn, "/shipments/upload", %{kerry_report: upload})

      assert redirected_to(conn2) == "/shipments"
      assert get_flash(conn2, :info) =~ "Uploaded Kerry Report."
      assert get_flash(conn2, :info) =~ "13 Rows Processed. 0 Shipments Added."

      assert length(Shipment.all()) == 13
    end

    @tag login_as: "user"
    test "POST /shipments/:id/send_message with non admin user", %{conn: conn} do
      shipment = insert(:shipment)
      conn = post(conn, "/shipments/#{shipment.id}/send_message")
      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "POST /shipments/:id/send_message", %{conn: conn} do
      shipment = insert(:shipment)
      shortened_url = "http://short.url/abc"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name} #{shortened_url}"

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        with_mock URLShortener, shorten_url: fn _url -> {:ok, shortened_url} end do
          conn = post(conn, "/shipments/#{shipment.id}/send_message")
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called(URLShortener.shorten_url(shipment |> Shipment.tracking_url()))
          assert called(Messages.send_message_to_shipment(expected_message, :_, :_))
        end
      end
    end

    @tag login_as: "admin", admin: true
    test "POST /shipments/:id/send_message when shipments belongs to sender, without credits", %{conn: conn} do
      sender = insert(:sender)
      shipment = insert(:shipment, sender_phone: sender.phone)
      shortened_url = "http://short.url/abc"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name} #{shortened_url}"

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        with_mock URLShortener, shorten_url: fn _url -> {:ok, shortened_url} end do
          conn = post(conn, "/shipments/#{shipment.id}/send_message")
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :error) =~ "Message Not Sent. Insufficient Credit."
          refute called(URLShortener.shorten_url(shipment |> Shipment.tracking_url()))
          refute called(Messages.send_message_to_shipment(expected_message, :_, :_))
        end
      end

      assert Credits.get_sender_credit(sender) == 0
    end

    @tag login_as: "admin", admin: true
    test "POST /shipments/:id/send_message when shipments belongs to sender, with credits", %{conn: conn} do
      sender = insert(:sender)
      shipment = insert(:shipment, sender_phone: sender.phone)
      Credits.add_credit_to_sender(100, sender)
      shortened_url = "http://short.url/abc"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name} #{shortened_url}"

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        with_mock URLShortener, shorten_url: fn _url -> {:ok, shortened_url} end do
          conn = post(conn, "/shipments/#{shipment.id}/send_message")
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called(URLShortener.shorten_url(shipment |> Shipment.tracking_url()))
          assert called(Messages.send_message_to_shipment(expected_message, :_, :_))
        end
      end

      # Deducts sender credit by -1
      sender = shipment |> Shipment.get_sender()
      assert Credits.get_sender_credit(sender) == 100 - 1
    end

    @tag login_as: "admin", admin: true
    test "trims sender name to make message not longer than 70 chars", %{conn: conn} do
      shipment = insert(:shipment, sender_name: String.duplicate("ที่", 20))
      shortened_url = "short.url/abcd"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{String.duplicate("ที่", 10)} #{shortened_url}"

      assert String.to_charlist(expected_message) |> length() == 70

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        with_mock URLShortener, shorten_url: fn _url -> {:ok, shortened_url} end do
          conn = post(conn, "/shipments/#{shipment.id}/send_message")
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called(URLShortener.shorten_url(shipment |> Shipment.tracking_url()))
          assert called(Messages.send_message_to_shipment(expected_message, :_, :_))
        end
      end
    end

    @tag login_as: "admin", admin: true
    test "omits tracking url if url shorten fails", %{conn: conn} do
      shipment = insert(:shipment)
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name}"

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        with_mock URLShortener, shorten_url: fn _url -> {:error, "FAILURE"} end do
          conn = post(conn, "/shipments/#{shipment.id}/send_message")
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called(URLShortener.shorten_url(shipment |> Shipment.tracking_url()))
          assert called(Messages.send_message_to_shipment(expected_message, :_, :_))
        end
      end
    end

    @tag login_as: "admin", admin: true
    test "POST send_message when already have one message", %{conn: conn} do
      shipment = insert(:shipment, messages: [build(:message)])

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:ok, %Message{}} end do
        conn = post(conn, "/shipments/#{shipment.id}/send_message")
        assert redirected_to(conn) == "/shipments"
        assert get_flash(conn, :info) =~ "Message Sent."
        assert called(Messages.send_message_to_shipment(:_, :_, :_))
      end
    end

    @tag login_as: "admin", admin: true
    test "POST send_message when send_message_to_shipment returns error", %{conn: conn} do
      shipment = insert(:shipment, messages: [build(:message)])

      msg = "Unexpected error occurred."

      with_mock Messages,
        send_message_to_shipment: fn _message, %Shipment{}, _resent -> {:error, msg} end do
        conn = post(conn, "/shipments/#{shipment.id}/send_message")
        assert redirected_to(conn) == "/shipments"
        assert get_flash(conn, :error) =~ msg
        assert called(Messages.send_message_to_shipment(:_, :_, :_))
      end
    end
  end

  describe "GET upload_pending" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "user"
    test "redirect to root page", %{conn: conn} do
      conn = get(conn, "/shipments/upload_pending")

      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "renders upload pending page", %{conn: conn} do
      conn = get(conn, "/shipments/upload_pending")

      assert html_response(conn, 200) =~ "Upload Kerry Pending Report"
    end
  end

  describe "POST upload_pending" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "admin", admin: true
    test "without xlsx file returns error", %{conn: conn} do
      conn = post(conn, "/shipments/upload_pending")
      assert redirected_to(conn) == "/shipments/upload_pending"
      assert get_flash(conn, :error) == "Kerry Pending Report File Needed"
    end

    @tag login_as: "admin", admin: true
    test "with xlsx file", %{conn: conn} do
      upload = %Plug.Upload{
        path: "../../apps/kerry_sheet_parser/test/fixtures/HPPY_Pending-3-11-61.xlsx",
        filename: "HPPY_Pending-3-11-61.xlsx"
      }

      conn = post(conn, "/shipments/upload_pending", %{kerry_pending_report: upload})

      assert redirected_to(conn) == "/shipments"
      assert get_flash(conn, :info) =~ "Uploaded Kerry Pending Report."
      assert get_flash(conn, :info) =~ "92 Rows Processed."
    end
  end
end
