defmodule Evolution.AuthView do
  use Evolution.Web, :view

  def render("signup.json", %{token: token}) do
    %{
      token: token
    }
  end

  def render("signup.json", %{changeset: changeset}) do
    %{errors: changeset.errors |> Enum.map(&error_json/1) |> Enum.into(%{})}
  end
end
