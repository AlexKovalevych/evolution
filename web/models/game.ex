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
    # field :current_stage, :string
    field :players_number, :integer
    # belongs_to :current_turn, Evolution.CurrentTurn
    belongs_to :creator, Evolution.User

    timestamps()
  end

  @required_fields ~w(completed players_number creator_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
