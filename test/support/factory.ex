defmodule Evolution.Factory do
  use ExMachina.Ecto, repo: Evolution.Repo
  use Evolution.UserFactory
end
