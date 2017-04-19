defmodule Evolution.AuthController do
  use Evolution.Web, :controller
  alias Evolution.User
  alias Evolution.UserFromAuth

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> render("login.json", error: "Failed to login")
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: private_page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not authenticate. Error: #{_reason}")
        |> render("login.html", current_user: current_user, current_auths: auths(current_user))
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  # def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
  #   case User.validate_password(auth.credentials) do
  #     :ok ->
  #       user = %{id: auth.uid, name: name_from_auth(auth)}
  #       conn
  #       |> put_flash(:info, "Successfully authenticated.")
  #       |> put_session(:current_user, user)
  #       |> redirect(to: "/")
  #     { :error, reason } ->
  #       conn
  #       |> put_flash(:error, reason)
  #       |> redirect(to: "/")
  #   end
  # end

  def login(conn, _params) do
    render conn, "index.html"
  end

  # def login(conn, params) do
  #   case User.find_and_confirm_password(params) do
  #     {:ok, user} ->
  #       conn
  #       |> Guardian.Plug.sign_in(user)
  #       |> render("login.json", token: Guardian.Plug.current_token(conn), user: user)
  #     {:error, changeset} ->
  #       conn
  #       |> render "login.json", changeset: changeset
  #   end
  # end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)

    |> Guardian.Plug.sign_out()
    |> text("")
  end

  def signup(conn, %{"login" => login, "password" => password} = params) do
    changeset = User.changeset(%User{}, params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn = Guardian.Plug.sign_in(conn, user)
        conn
        |> render "login.json", token: Guardian.Plug.current_token(conn), user: user
      {:error, changese} ->
        conn
        |> render "signup.json", changeset: changeset
    end
  end

  def signup(conn, _params) do
    render conn, "index.html"
  end

end
