require IEx
defmodule ShipchoiceBackend.SenderControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(ShipchoiceDb.Repo)
  end

  test "GET /senders", %{conn: conn} do
    conn = get conn, "/senders"
    assert html_response(conn, 200) =~ "All Senders"
    assert html_response(conn, 200) =~ "Add New Sender"
  end

  test "GET /senders with existing senders", %{conn: conn} do
    senders = [
      %{name: "Foo", phone: "0812345678"},
      %{name: "Bar", phone: "0898765432"},
    ]

    senders
    |> Enum.each(fn(sender) -> ShipchoiceDb.Sender.insert(sender) end)

    conn = get conn, "/senders"

    assert html_response(conn, 200) =~ "Foo"
    assert html_response(conn, 200) =~ "0812345678"
    assert html_response(conn, 200) =~ "Bar"
    assert html_response(conn, 200) =~ "0898765432"
  end

  test "GET /senders/new", %{conn: conn} do
    conn = get conn, "/senders/new"

    assert html_response(conn, 200) =~ "Add New Sender"
  end

  test "POST /senders", %{conn: conn} do
    conn = post conn,
                "/senders",
                %{
                  sender: %{
                    name: "Foo",
                    phone: "0812345678"
                  }
                }

    assert redirected_to(conn) == "/senders"
    assert get_flash(conn, :info) =~ "Added New Sender."

    assert length(ShipchoiceDb.Sender.all) == 1
  end
end
