defmodule ShipchoiceBackend.IssueControllerTest do
  use ShipchoiceBackend.ConnCase

  alias Ecto.Adapters.SQL.Sandbox
  alias ShipchoiceDb.{Issue, Repo}

  import ShipchoiceDb.Factory

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, issue_path(conn, :index)),
        get(conn, issue_path(conn, :upload_pending)),
        post(conn, issue_path(conn, :do_upload_pending)),
        post(conn, issue_path(conn, :resolve, 1)),
        post(conn, issue_path(conn, :undo_resolve, 1)),
        post(conn, issue_path(conn, :update_note, 1)),
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == "/sessions/new"
        assert get_flash(conn, :error) == "You must be signed in to access that page."
        assert conn.halted
      end
    )
  end

  describe "GET index" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "user"
    test "user is not allowed to view all issues", %{conn: conn} do
      conn = get(conn, "/issues")

      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "admin can view all issues", %{conn: conn} do
      issues = insert_list(2, :issue)

      conn = get(conn, "/issues")

      assert html_response(conn, 200) =~ "All Issues"
      assert html_response(conn, 200) =~ "Mark Resolved"
      assert html_response(conn, 200) =~ Enum.at(issues, 0).shipment_number
      assert html_response(conn, 200) =~ Enum.at(issues, 1).shipment_number
    end

    @tag login_as: "admin", admin: true
    test "admin can view resolved issues", %{conn: conn} do
      time = DateTime.utc_now()
      _issues = insert_list(2, :issue, resolved_at: time)

      conn = get(conn, "/issues")

      assert html_response(conn, 200) =~ "All Issues"
      assert html_response(conn, 200) =~ "Undo Resolve"
      # assert html_response(conn, 200) =~ time |> Timex.format!("{relative}", :relative)
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
      conn = get(conn, "/issues/upload_pending")

      assert redirected_to(conn) == "/"
      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "Not allowed."
    end

    @tag login_as: "admin", admin: true
    test "renders upload pending page", %{conn: conn} do
      conn = get(conn, "/issues/upload_pending")

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
      conn = post(conn, "/issues/upload_pending")
      assert redirected_to(conn) == "/issues/upload_pending"
      assert get_flash(conn, :error) == "Kerry Pending Report File Needed"
    end

    @tag login_as: "admin", admin: true
    test "with xlsx file inserts issues", %{conn: conn} do
      upload = %Plug.Upload{
        path: "../../apps/kerry_sheet_parser/test/fixtures/HPPY_Pending-3-11-61.xlsx",
        filename: "HPPY_Pending-3-11-61.xlsx"
      }

      conn = post(conn, "/issues/upload_pending", %{kerry_pending_report: upload})

      assert redirected_to(conn) == "/issues"
      assert get_flash(conn, :info) =~ "Uploaded Kerry Pending Report."
      assert get_flash(conn, :info) =~ "92 Rows Processed."
      assert get_flash(conn, :info) =~ "92 Issues Added."

      assert length(Issue.all()) == 92
    end
  end

  describe "POST resolve" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "admin", admin: true
    test "sets issue as resolved", %{conn: conn} do
      issue = insert(:issue)

      conn = post(conn, "/issues/#{issue.id}/resolve")

      assert conn.resp_body =~ "Undo Resolve"

      refute Issue.get(issue.id).resolved_at |> is_nil()
    end
  end

  describe "POST update_note" do
    setup options do
      %{conn: conn, login_as: username, admin: admin} =
        Enum.into(options, %{admin: false})
      factory = if admin, do: :admin_user, else: :user
      user = insert(factory, username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "admin", admin: true
    test "updates note", %{conn: conn} do
      issue = insert(:issue)

      conn = post(conn, "/issues/#{issue.id}/update_note", note: "Hello")

      body = json_response(conn, 200)
      assert body["success"]
      assert Issue.get(issue.id).note == "Hello"
    end
  end
end
