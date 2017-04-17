defmodule Evolution.AuthController do
  use Evolution.Web, :controller
  alias Evolution.User

  def login(conn, _params) do
    render conn, "index.html"
  end

  def signup(conn, %{"login" => login, "password" => password} = params) do
    changeset = User.changeset(%User{}, params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        Guardian.Plug.sign_in(conn, user)
        conn
        |> render "signup.json", token: Guardian.Plug.current_token(conn)
      {:error, changese} ->
        conn
        |> render "signup.json", changeset: changeset
    end
  end

  def signup(conn, _params) do
    render conn, "index.html"
  end

end
