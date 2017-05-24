defmodule Evolution.GameTest do
  use Evolution.ModelCase

  alias Evolution.Game

  @valid_attrs %{completed: true, players_number: 2, creator_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Game.changeset(%Game{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Game.changeset(%Game{}, @invalid_attrs)
    refute changeset.valid?
  end
end
