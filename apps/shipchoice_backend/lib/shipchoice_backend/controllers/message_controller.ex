defmodule ShipchoiceBackend.MessageController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.Message

  plug(:authenticate_user)

  def index(conn, params) do
    page =
      Message
      |> Message.search(get_in(params, ["search"]))
      |> ShipchoiceDb.Repo.paginate(params)

    render(
      conn,
      "index.html",
      messages: page.entries,
      page: page
    )
  end
end
