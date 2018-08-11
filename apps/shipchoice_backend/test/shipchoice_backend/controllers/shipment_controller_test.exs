defmodule ShipchoiceBackend.ShipmentControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceBackend.Messages
  alias ShipchoiceDb.{Shipment, Message, Repo}

  import Mock
  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, shipment_path(conn, :index)),
      get(conn, shipment_path(conn, :upload)),
      post(conn, shipment_path(conn, :do_upload)),
      post(conn, shipment_path(conn, :send_message, 1)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/sessions/new"
      assert get_flash(conn, :error) == "You must be signed in to access that page."
      assert conn.halted
    end)
  end

  describe "with a signed in user" do
    setup %{conn: conn, login_as: username} do
      user = insert(:user, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "narze"
    test "GET /shipments", %{conn: conn} do
      conn = get conn, "/shipments"
      assert html_response(conn, 200) =~ "All Shipments"
      assert html_response(conn, 200) =~ "Upload Kerry Report"
    end

    @tag login_as: "narze"
    test "GET /shipments with existing shipments", %{conn: conn} do
      shipments = [
        %{shipment_number: "SHP0001"},
        %{shipment_number: "SHP0002"},
      ]

      shipments
      |> Enum.each(fn(shipment) -> ShipchoiceDb.Shipment.insert(shipment) end)

      conn = get conn, "/shipments"

      assert html_response(conn, 200) =~ "SHP0001"
      assert html_response(conn, 200) =~ "SHP0002"
    end

    @tag login_as: "narze"
    test "GET /shipments/upload", %{conn: conn} do
      conn = get conn, "/shipments/upload"
      assert html_response(conn, 200) =~ "Upload Kerry Report"
    end

    @tag login_as: "narze"
    test "POST /shipments/upload", %{conn: conn} do
      conn = post conn, "/shipments/upload"
      assert redirected_to(conn) == "/shipments/upload"
      assert get_flash(conn, :error) == "Kerry Report File Needed"
    end

    @tag login_as: "narze"
    test "POST /shipments/upload with xlsx file", %{conn: conn, user: user} do
      upload = %Plug.Upload{
        path: "test/fixtures/kerry.xlsx",
        filename: "kerry.xlsx",
      }

      conn = post conn,
                  "/shipments/upload",
                  %{kerry_report: upload}

      assert redirected_to(conn) == "/shipments"
      assert get_flash(conn, :info) =~ "Uploaded Kerry Report."
      assert get_flash(conn, :info) =~ "13 Rows Processed."

      assert length(ShipchoiceDb.Shipment.all) == 13

      # Recycle & manually assign current_user
      saved_assigns = conn.assigns
      conn =
        conn
        |> recycle()
        |> Map.put(:assigns, saved_assigns)

      # Upload again
      conn2 = post conn,
                  "/shipments/upload",
                  %{kerry_report: upload}

      assert redirected_to(conn2) == "/shipments"
      assert get_flash(conn2, :info) =~ "Uploaded Kerry Report."
      assert get_flash(conn2, :info) =~ "13 Rows Processed."

      assert length(ShipchoiceDb.Shipment.all) == 13
    end

    @tag login_as: "narze"
    test "POST /shipments/:id/send_message", %{conn: conn} do
      shipment = insert(:shipment)
      shortened_url = "http://short.url/abc"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{shipment.sender_name} #{shortened_url}"

      with_mock Messages,
                [send_message_to_shipment: fn(_message, %Shipment{}, _resent) -> {:ok, %Message{}} end] do
        with_mock URLShortener,
                [shorten_url: fn(_url) -> {:ok, shortened_url} end] do
          conn = post conn, "/shipments/#{shipment.id}/send_message"
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called URLShortener.shorten_url(shipment |> Shipment.tracking_url)
          assert called Messages.send_message_to_shipment(expected_message, :_, :_)
        end
      end
    end

    @tag login_as: "narze"
    test "trims sender name to make message not longer than 70 chars", %{conn: conn} do
      shipment = insert(:shipment, sender_name: String.duplicate("ที่", 20))
      shortened_url = "short.url/abcd"
      expected_message = "Kerry กำลังนำส่งพัสดุจาก #{String.duplicate("ที่", 10)} #{shortened_url}"

      assert String.to_charlist(expected_message) |> length() == 70

      with_mock Messages,
                [send_message_to_shipment: fn(_message, %Shipment{}, _resent) -> {:ok, %Message{}} end] do
        with_mock URLShortener,
                [shorten_url: fn(_url) -> {:ok, shortened_url} end] do
          conn = post conn, "/shipments/#{shipment.id}/send_message"
          assert redirected_to(conn) == "/shipments"
          assert get_flash(conn, :info) =~ "Message Sent."
          assert called URLShortener.shorten_url(shipment |> Shipment.tracking_url)
          assert called Messages.send_message_to_shipment(expected_message, :_, :_)
        end
      end
    end

    @tag login_as: "narze"
    test "POST send_message when already have one message", %{conn: conn} do
      shipment = insert(:shipment, messages: [build(:message)])

      with_mock Messages,
                [send_message_to_shipment: fn(_message, %Shipment{}, _resent) -> {:ok, %Message{}} end] do
        conn = post conn, "/shipments/#{shipment.id}/send_message"
        assert redirected_to(conn) == "/shipments"
        assert get_flash(conn, :info) =~ "Message Sent."
        assert called Messages.send_message_to_shipment(:_, :_, :_)
      end
    end

    @tag login_as: "narze"
    test "POST send_message when send_message_to_shipment returns error", %{conn: conn} do
      shipment = insert(:shipment, messages: [build(:message)])

      msg = "Unexpected error occurred."

      with_mock Messages,
                [send_message_to_shipment: fn(_message, %Shipment{}, _resent) -> {:error, msg} end] do
        conn = post conn, "/shipments/#{shipment.id}/send_message"
        assert redirected_to(conn) == "/shipments"
        assert get_flash(conn, :error) =~ msg
        assert called Messages.send_message_to_shipment(:_, :_, :_)
      end
    end
  end
end
