defmodule Evolution.AuthController do
  use Evolution.Web, :controller

  def auth(conn, _params) do
    render conn, "index.html"
  end

end
