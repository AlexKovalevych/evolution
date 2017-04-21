defmodule Evolution.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :completed, :boolean, default: false, null: false
      add :current_stage, :string
      add :current_turn, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:games, [:current_turn])

  end
end
