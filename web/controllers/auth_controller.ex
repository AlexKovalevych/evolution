defmodule Evolution.AuthController do
  use Evolution.Web, :controller
  alias Evolution.User
  alias Evolution.UserFromAuth
  use Guardian.Phoenix.Controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> render("login.json", error: "Failed to login")
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, current_user, _claims) do
    conn
    |> render("login.json", error: fails)
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user) do
      {:ok, user} ->
        conn = conn |> Guardian.Plug.sign_in(user)
        conn
        |> render("login.json", token: Guardian.Plug.current_token(conn), user: user)
      {:error, reason} ->
        conn
        |> render("signup.json", error: reason)
    end
  end

  def login(conn, _params, current_user, _claims) do
    render conn, "index.html"
  end

  def logout(conn, _params, _current_user, _claims) do
    conn
    |> configure_session(drop: true)
    |> Guardian.Plug.sign_out()
    |> text("")
  end

  def signup(conn, _params, current_user, _claims) do
    render conn, "index.html"
  end

end
