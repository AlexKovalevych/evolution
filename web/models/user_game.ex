defmodule Evolution.UserGame do
  use Evolution.Web, :model

  schema "user_games" do
    field :cards, {:array, :string}
    belongs_to :user, Evolution.User
    belongs_to :game, Evolution.Game
    has_many :animals, Evolution.UserGameAnimal

    timestamps()
  end

  @required_fields ~w(cards user_id game_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
