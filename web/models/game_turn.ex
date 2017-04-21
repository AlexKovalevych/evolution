defmodule Evolution.GameTurn do
  use Evolution.Web, :model

  schema "game_turns" do
    field :stage, :string
    field :type, :string
    field :data, :map
    belongs_to :game, Evolution.Game
    belongs_to :user, Evolution.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:stage, :type, :data])
    |> validate_required([:stage, :type, :data])
  end
end
