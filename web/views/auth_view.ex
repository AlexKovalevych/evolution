defmodule Evolution.AuthView do
  use Evolution.Web, :view

  def render("signup.json", %{token: token}) do
    %{
      token: token
    }
  end

  def render("signup.json", %{changeset: changeset}) do
    IO.inspect(changeset.errors)
    %{
      errors: changeset.errors
    }
  end
end
