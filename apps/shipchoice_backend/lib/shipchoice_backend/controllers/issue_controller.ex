defmodule ShipchoiceBackend.IssueController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.{Repo, Issue}

  plug(:authenticate_user)
  plug :authorize_admin when action in [
    :index,
    :upload_pending,
    :do_upload_pending,
  ]

  def index(conn, params) do
    page =
      Issue
      |> Repo.paginate(params)

    render(
      conn,
      "index.html",
      issues: page.entries,
      page: page
    )
  end

  def upload_pending(conn, _params) do
    render(conn, "upload_pending.html")
  end

  def do_upload_pending(conn, params) do
    unless kerry_pending_report = params["kerry_pending_report"] do
      conn
      |> put_flash(:error, "Kerry Pending Report File Needed")
      |> redirect(to: "/issues/upload_pending")
    else
      {:ok, rows} = KerrySheetParser.parse_pending_sheet(kerry_pending_report.path)

      {:ok, count: count, new: new} = Issue.insert_rows(rows)

      conn
      |> put_flash(
        :info,
        "Uploaded Kerry Pending Report. #{count} Rows Processed. #{new} Issues Added."
      )
      |> redirect(to: "/issues")
    end
  end
end
