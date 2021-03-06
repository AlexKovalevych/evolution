defmodule Evolution.UserGame do
  use Evolution.Web, :model

  schema "user_games" do
    field :cards, {:array, :string}, default: []
    field :finish_stage, :boolean, default: false
    belongs_to :user, Evolution.User
    belongs_to :game, Evolution.Game
    has_many :animals, Evolution.UserGameAnimal

    timestamps()
  end

  @required_fields ~w(user_id game_id)a

  @optional_fields ~w(cards finish_stage)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def take_cards(deck, number) do
    Enum.split(deck, number)
  end
end
