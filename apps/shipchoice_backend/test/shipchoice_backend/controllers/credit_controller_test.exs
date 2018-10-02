defmodule ShipchoiceBackend.CreditControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.Repo

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    sender = insert(:sender)
    Enum.each(
      [
        get(conn, sender_credit_path(conn, :new, sender)),
        post(conn, sender_credit_path(conn, :create, sender, %{"amount" => 100})),
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
    setup %{conn: conn, login_as: name} do
      user = insert(:admin_user, name: name, username: name)
      conn = assign(conn, :current_user, user)
      sender = insert(:sender)

      {:ok, conn: conn, sender: sender}
    end

    @tag login_as: "narze"
    test "GET /senders/:id/credits/new", %{conn: conn, sender: sender} do
      conn = get(conn, "/senders/#{sender.id}/credits/new")
      assert html_response(conn, 200) =~ "Add Credits"
    end

    @tag login_as: "narze"
    test "POST /senders/:id/credits", %{conn: conn, sender: sender} do
      conn =
        post(conn, "/senders/#{sender.id}/credits", %{
          amount: "100"
        })

      assert redirected_to(conn) == "/senders"
      assert get_flash(conn, :info) =~ "Added Credits."
    end
  end
end
