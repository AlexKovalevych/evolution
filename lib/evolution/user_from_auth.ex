defmodule Evolution.UserFromAuth do
  alias Evolution.User
  alias Evolution.Authorization
  alias Ueberauth.Auth
  alias Evolution.Repo
  import Evolution.Gettext

  def get_or_insert(auth, current_user) do
    case auth_and_validate(auth) do
      {:error, {:login, reason}} -> {:error, {:login, reason}}
      {:error, :not_found} -> register_user_from_auth(auth, current_user)
      {:error, reason} -> {:error, reason}
      authorization ->
        if authorization.expires_at && authorization.expires_at < Guardian.Utils.timestamp do
          replace_authorization(authorization, auth, current_user)
        else
          user_from_authorization(authorization, current_user)
        end
    end
  end

  # We need to check the pw for the identity provider
  defp validate_auth_for_registration(%Auth{provider: :identity} = auth) do
    pw = Map.get(auth.credentials.other, :password)
    pwc = Map.get(auth.credentials.other, :password_confirmation)
    nickname = uid_from_auth(auth)
    case pw do
      nil ->
        {:error, {:password, dgettext("errors", "can't be blank")}}
      "" ->
        {:error, {:password, dgettext("errors", "can't be blank")}}
      ^pwc ->
        validate_pw_length(pw, nickname)
      _ ->
        {:error, {:password_confirmation, dgettext("errors", "does not match confirmation")}}
    end
  end

  # All the other providers are oauth so should be good
  defp validate_auth_for_registration(auth), do: :ok

  defp validate_pw_length(pw, nickname) when is_binary(pw) do
    if String.length(pw) >= 8 do
      validate_nickname(nickname)
    else
      {:error, {:password, dngettext("errors",
          "should be at least %{count} character(s)",
          "should be at least %{count} character(s)",
          8)}}
    end
  end

  # defp validate_email(email) when is_binary(email) do
  #   case Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, email) do
  #     nil ->
  #       {:error, :invalid_email}
  #     [email] ->
  #       :ok
  #   end
  # end

  defp validate_nickname(nickname) when is_binary(nickname) do
    if String.length(nickname) >= 4 do
      :ok
    else
      {:error, {:login, dngettext("errors",
          "should be at least %{count} character(s)",
          "should be at least %{count} character(s)",
          4)}}
    end
  end

  defp register_user_from_auth(auth, current_user) do
    case validate_auth_for_registration(auth) do
      :ok ->
        case Repo.transaction(fn -> create_user_from_auth(auth, current_user) end) do
          {:ok, response} -> response
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp replace_authorization(authorization, auth, current_user) do
    case validate_auth_for_registration(auth) do
      :ok ->
        case user_from_authorization(authorization, current_user) do
          {:ok, user} ->
            case Repo.transaction(fn ->
              Repo.delete(authorization)
              authorization_from_auth(user, auth)
              user
            end) do
              {:ok, user} -> {:ok, user}
              {:error, reason} -> {:error, reason}
            end
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_from_authorization(authorization, current_user) do
    case Repo.one(Ecto.assoc(authorization, :user)) do
      nil -> {:error, :user_not_found}
      user ->
        if current_user && current_user.id != user.id do
          {:error, :user_does_not_match}
        else
          {:ok, user}
        end
    end
  end

  defp create_user_from_auth(auth, current_user) do
    user = current_user
    unless user, do: user = Repo.get_by(User, login: uid_from_auth(auth))
    unless user, do: user = create_user(auth)
    authorization_from_auth(user, auth)
    {:ok, user}
  end

  defp create_user(auth) do
    result = %User{}
    |> User.registration_changeset(scrub(%{login: uid_from_auth(auth)}))
    |> Repo.insert
    case result do
      {:ok, user} -> user
      {:error, reason} -> Repo.rollback(reason)
    end
  end

  defp auth_and_validate(%{provider: :identity} = auth) do
    uid = uid_from_auth(auth)
    if uid == "" do
      {:error, {:login, dgettext("errors", "can't be blank")}}
    else
      # Define whether its login or signup. Probably there is a better way to do this
      if Map.has_key?(auth.extra.raw_info, "password_confirmation") do
        case Repo.get_by(Authorization, uid: uid, provider: to_string(auth.provider)) do
          nil -> {:error, :not_found}
          authorization -> {:error, {:login, dgettext("auth", "user exists")}}
        end
      else
        case Repo.get_by(Authorization, uid: uid, provider: to_string(auth.provider)) do
          nil ->
            {:error, {:login, dgettext("auth", "wrong credentials")}}
          authorization ->
            case auth.credentials.other.password do
              pass when is_binary(pass) ->
                if Comeonin.Bcrypt.checkpw(auth.credentials.other.password, authorization.token) do
                  authorization
                else
                  {:error, {:login, dgettext("auth", "wrong credentials")}}
                end
              _ -> {:error, {:login, dgettext("auth", "wrong credentials")}}
            end
        end
      end
    end
  end

  # defp auth_and_validate(%{provider: service} = auth, repo)  when service in [:google, :facebook, :github] do
  #   case repo.get_by(Authorization, uid: uid_from_auth(auth), provider: to_string(auth.provider)) do
  #     nil -> {:error, :not_found}
  #     authorization ->
  #       if authorization.uid == uid_from_auth(auth) do
  #         authorization
  #       else
  #         {:error, :uid_mismatch}
  #       end
  #   end
  # end

  # defp auth_and_validate(auth, repo) do
  #   case repo.get_by(Authorization, uid: uid_from_auth(auth), provider: to_string(auth.provider)) do
  #     nil -> {:error, :not_found}
  #     authorization ->
  #       if authorization.token == auth.credentials.token do
  #         authorization
  #       else
  #         {:error, :token_mismatch}
  #       end
  #   end
  # end

  defp authorization_from_auth(user, auth) do
    result = user
    |> Ecto.build_assoc(:authorizations)
    |> Authorization.changeset(
      scrub(
        %{
          provider: to_string(auth.provider),
          uid: uid_from_auth(auth),
          token: token_from_auth(auth),
          refresh_token: auth.credentials.refresh_token,
          expires_at: auth.credentials.expires_at,
          password: password_from_auth(auth),
          password_confirmation: password_confirmation_from_auth(auth)
        }
      )
    )
    |> Repo.insert

    case result do
      {:ok, the_auth} -> the_auth
      {:error, reason} -> Repo.rollback(reason)
    end
  end

  defp token_from_auth(%{provider: :identity} = auth) do
    case auth do
      %{ credentials: %{ other: %{ password: pass } } } when not is_nil(pass) ->
        Comeonin.Bcrypt.hashpwsalt(pass)
      _ -> nil
    end
  end

  defp token_from_auth(auth), do: auth.credentials.token

  # defp uid_from_auth(%{ provider: :slack } = auth), do: auth.credentials.other.user_id
  defp uid_from_auth(auth), do: to_string(auth.uid)

  defp password_from_auth(%{provider: :identity} = auth), do: auth.credentials.other.password
  defp password_from_auth(_), do: nil

  defp password_confirmation_from_auth(%{provider: :identity} = auth) do
    auth.credentials.other.password_confirmation
  end
  defp password_confirmation_from_auth(_), do: nil

  # We don't have any nested structures in our params that we are using scrub with so this is a very simple scrub
  defp scrub(params) do
    result = params
    |> Enum.filter(fn
      {key, val} when is_binary(val) -> String.strip(val) != ""
      {key, val} when is_nil(val) -> false
      _ -> true
    end)
    |> Enum.into(%{})
    result
  end
end
