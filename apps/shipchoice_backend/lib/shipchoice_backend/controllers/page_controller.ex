defmodule ShipchoiceBackend.PageController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    if current_user = conn.assigns[:current_user] do

      current_user =
        current_user
        |> ShipchoiceDb.Repo.preload(:senders)

      senders = current_user.senders

      render(
        conn,
        "index.html",
        senders: senders,
        current_user: current_user
      )
    else
      render(
        conn,
        "index.html",
        current_user: nil
      )
    end
  end
end
