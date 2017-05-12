defmodule Evolution.Game do
  @moduledoc """
  :red - кормовая база
  :blue - дополнительная еда
  :yellow - жировой запас
  """

  use Evolution.Web, :model

  @derive {Poison.Encoder, only: [:id, :completed, :players_number, :inserted_at, :updated_at]}

  schema "games" do
    field :completed, :boolean, default: false
    field :players_number, :integer
    field :deck, {:array, :string}, default: []
    field :discard_pile, {:array, :string}, default: []
    field :turn_order, {:array, :integer}, default: []
    field :fsm_state, :string
    belongs_to :creator, Evolution.User
    belongs_to :current_turn, Evolution.User
    has_many :players, Evolution.UserGame

    timestamps()
  end

  @required_fields ~w(completed players_number creator_id)a

  @optional_fields ~w(turn_order deck discard_pile current_turn_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
