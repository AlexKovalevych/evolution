defmodule Evolution.GameTurnTest do
  use Evolution.ModelCase

  alias Evolution.GameTurn

  @valid_attrs %{data: %{}, stage: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GameTurn.changeset(%GameTurn{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GameTurn.changeset(%GameTurn{}, @invalid_attrs)
    refute changeset.valid?
  end
end
