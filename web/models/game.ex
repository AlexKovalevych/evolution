defmodule Evolution.Game do
  use Evolution.Web, :model

  schema "games" do
    field :completed, :boolean, default: false
    field :current_stage, :string
    belongs_to :current_turn, Evolution.CurrentTurn

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:completed, :current_stage])
    |> validate_required([:completed, :current_stage])
  end
end
