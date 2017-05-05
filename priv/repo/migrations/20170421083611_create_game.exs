defmodule Evolution.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :completed, :boolean, default: false, null: false
      # add :current_stage, :string
      # add :current_turn_id, references(:users, on_delete: :nothing)
      add :players_number, :integer
      add :creator_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    # create index(:games, [:current_turn_id])

  end
end
