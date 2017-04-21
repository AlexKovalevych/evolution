defmodule Evolution.GameUserTest do
  use Evolution.ModelCase

  alias Evolution.GameUser

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GameUser.changeset(%GameUser{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GameUser.changeset(%GameUser{}, @invalid_attrs)
    refute changeset.valid?
  end
end
