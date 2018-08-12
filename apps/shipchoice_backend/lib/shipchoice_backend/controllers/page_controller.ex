defmodule ShipchoiceBackend.PageController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
