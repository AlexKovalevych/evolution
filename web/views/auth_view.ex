defmodule Evolution.AuthView do
  use Evolution.Web, :view

  def render("login.json", %{token: token, user: user}) do
    %{
      token: token,
      user: user
    }
  end

  def render("signup.json", %{error: {field, error}}) do
    errors = Map.new() |> Map.put(field, error)
    %{errors: errors}
  end
end
