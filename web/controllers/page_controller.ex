defmodule Evolution.PageController do
  use Evolution.Web, :controller
  use Guardian.Phoenix.Controller

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params, user, _claims) do
    render conn, "index.html", user: user
  end

  def unauthenticated(conn, _) do
    conn
    |> redirect(to: login_path(conn, :auth))
  end
end
