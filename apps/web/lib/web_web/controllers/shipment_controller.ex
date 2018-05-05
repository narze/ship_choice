defmodule WebWeb.ShipmentController do
  use WebWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
