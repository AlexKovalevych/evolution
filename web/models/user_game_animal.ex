defmodule Evolution.UserGameAnimal do
  use Evolution.Web, :model

  # @derive {Poison.Encoder, only: [:id, :completed, :players_number, :inserted_at, :updated_at]}

  schema "user_game_animals" do
    field :card, :string
    field :properties, {:array, :string}
    field :food, :integer       # red points
    field :extra_food, :integer # blue points
    field :fat, :integer        # yellow points
    belongs_to :user_game, Evolution.UserGame
    belongs_to :cooperation, Evolution.UserGameAnimal
    belongs_to :interaction, Evolution.UserGameAnimal

    timestamps()
  end

  @required_fields ~w(user_game_id card)a

  @optional_fields ~w(cooperation_id interaction_id properties food extra_food fat)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

end
