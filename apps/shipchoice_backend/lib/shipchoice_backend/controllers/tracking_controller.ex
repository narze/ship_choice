defmodule ShipchoiceBackend.TrackingController do
  use ShipchoiceBackend, :controller

  def tracking(conn, %{"number" => number}) do
    conn
    |> redirect(external: "https://th.kerryexpress.com/en/track/?track=#{number}")
  end
end
