defmodule Evolution.GameUser do
  use Evolution.Web, :model

  schema "game_users" do
    belongs_to :game, Evolution.Game
    belongs_to :user, Evolution.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
