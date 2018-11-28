defmodule ShipchoiceBackend.IssueController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.{Repo, Issue}

  plug(:authenticate_user)
  plug :authorize_admin when action in [
    :index,
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
end
