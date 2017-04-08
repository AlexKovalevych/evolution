defmodule Evolution.PageController do
  use Evolution.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
