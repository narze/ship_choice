defmodule ShipchoiceBackend.IssueController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.{Repo, Issue}
  import Ecto.Query, only: [order_by: 2]

  plug(:authenticate_user)
  plug :authorize_admin when action in [
    :index,
    :upload_pending,
    :do_upload_pending,
    :resolve,
    :undo_resolve,
    :update_note,
  ]

  def index(conn, params) do
    page =
      Issue
      |> Issue.search(get_in(params, ["search"]))
      |> Issue.by_resolved(get_in(params, ["resolved"]))
      |> order_by(desc: :inserted_at)
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

      (conn
      |> put_flash(
        :info,
        "Uploaded Kerry Pending Report. #{count} Rows Processed. #{new} Issues Added."
      )
      |> redirect(to: "/issues"))
    end
  end

  def resolve(conn, %{"id" => id}) do
    {:ok, issue} =
      Issue.get(id)
      |> Issue.update(%{resolved_at: DateTime.utc_now()})

    conn
    |> put_layout(false)
    |> render("issue.html", issue: issue)
  end

  def undo_resolve(conn, %{"id" => id}) do
    {:ok, issue} =
      Issue.get(id)
      |> Issue.update(%{resolved_at: nil})

    conn
    |> put_layout(false)
    |> render("issue.html", issue: issue)
  end

  def update_note(conn, %{"id" => id, "note" => note}) do
    {:ok, _issue} =
      Issue.get(id)
      |> Issue.update(%{note: note})

    conn
    |> render("update_note.json", success: true)
  end
end
