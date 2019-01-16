defmodule ShipchoiceBackend.MessageControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Repo}

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, message_path(conn, :index))
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
    test "GET /messages", %{conn: conn} do
      conn = get(conn, "/messages")
      assert html_response(conn, 200) =~ "All Messages"
    end

    @tag login_as: "narze"
    test "GET /messages with existing messages", %{conn: conn} do
      shipment = build(:shipment)

      messages = [
        %{message: "Hello", sent_at: DateTime.utc_now, shipment: shipment},
        %{message: "World"}
      ]

      messages =
        messages
        |> Enum.map(fn message -> insert(:message, message) end)

      conn = get(conn, "/messages")

      assert html_response(conn, 200) =~ "Hello"
      assert html_response(conn, 200) =~ "World"
      # assert html_response(conn, 200) =~ "List.first(messages).sent_at |> Timex.format!("{relative}", :relative)"
      assert html_response(conn, 200) =~ List.first(messages).phone
      assert html_response(conn, 200) =~ shipment.shipment_number
    end

    @tag login_as: "narze"
    test "GET /messages with search term", %{conn: conn} do
      messages = [
        %{message: "Hello"},
        %{message: "World"}
      ]

      messages
      |> Enum.each(fn message -> insert(:message, message) end)

      conn = get(conn, "/messages?search=ell")

      assert html_response(conn, 200) =~ "Hello"
      refute html_response(conn, 200) =~ "World"
    end
  end
end
