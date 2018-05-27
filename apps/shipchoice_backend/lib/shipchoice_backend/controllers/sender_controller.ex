defmodule ShipchoiceBackend.SenderController do
  use ShipchoiceBackend, :controller

  def index(conn, _params) do
    senders = ShipchoiceDb.Sender.all
    render conn, "index.html", senders: senders
  end
end
