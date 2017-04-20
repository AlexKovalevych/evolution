defmodule Evolution.User do
  @derive {Poison.Encoder, only: [:id, :login]}

  use Evolution.Web, :model
  alias Evolution.Authorization

  schema "users" do
    field :login, :string
    field :password, :string, virtual: true

    has_many :authorizations, Authorization, on_replace: :delete

    timestamps()
  end

  @required_fields ~w(login password)a

  @optional_fields ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_confirmation(:password)
    |> validate_length(:login, min: 4)
    |> validate_length(:password, min: 4)
    |> unique_constraint(:login)
  end

  @doc """
  Returns user from auth or error with reason
  """
  @spec from_auth(%Ueberauth.Auth{provider: :identity}) :: {:error, String.t} | {:ok, user}
  def from_auth(%{provider: :identity} = auth) do
    user = __MODULE__
    |> select([u], u)
    |> preload(:authorizations)
    |> Repo.get_by(login: uid_from_auth(auth))
    case user do
      nil -> {:error, dgettext("login", "invalid_credentials")}
      user ->
        with {:ok, authorization} <- provider_auth(user, auth.provider),
             true                 <- Comeonin.Bcrypt.checkpw(auth.credentials.other.password, authorization.token) do
          login(user) |> Repo.update
        else
          true -> {:error, dgettext("login", "user_disabled")}
        false ->
            login_failed(user) |> Repo.update!
            {:error, dgettext("login", "invalid_credentials")}
          {:error, reason} -> {:error, reason}
        end
    end
  end


end
