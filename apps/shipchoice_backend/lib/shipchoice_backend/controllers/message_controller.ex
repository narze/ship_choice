defmodule ShipchoiceBackend.MessageController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.Message

  plug(:authenticate_user)

  def index(conn, params) do
    page =
      Message
      |> Message.search(get_in(params, ["search"]))
      |> ShipchoiceDb.Repo.paginate(params)

    entries = ShipchoiceDb.Repo.preload(page.entries, :shipment)

    render(
      conn,
      "index.html",
      messages: entries,
      page: page
    )
  end
end
