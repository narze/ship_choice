defmodule ShipchoiceBackend.PageControllerTest do
  use ShipchoiceBackend.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to ShypChoice!"
  end
end
