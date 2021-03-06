defmodule Evolution.AuthorizationTest do
  use Evolution.ModelCase

  alias Evolution.Authorization

  @valid_attrs %{expires_at: 42, provider: "some content", token: "some content", uid: "1", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @invalid_attrs)
    refute changeset.valid?
  end
end
