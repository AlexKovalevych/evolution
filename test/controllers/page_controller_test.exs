defmodule Evolution.PageControllerTest do
  use Evolution.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn, 302) =~ "/login"
  end

  test "GET /login", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200)
  end
end
