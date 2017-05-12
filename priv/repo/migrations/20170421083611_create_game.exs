defmodule Evolution.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :completed, :boolean, default: false, null: false
      add :players_number, :integer
      add :deck, {:array, :string}, default: []
      add :discard_pile, {:array, :string}, default: []
      add :turn_order, {:array, :integer}, default: []
      add :fsm_state, :string
      add :creator_id, references(:users, on_delete: :nothing)
      add :current_turn_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
