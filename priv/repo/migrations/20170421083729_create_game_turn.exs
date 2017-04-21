defmodule Evolution.Repo.Migrations.CreateGameTurn do
  use Ecto.Migration

  def change do
    create table(:game_turns) do
      add :stage, :string
      add :type, :string
      add :data, :map
      add :game, references(:games, on_delete: :nothing)
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:game_turns, [:game])
    create index(:game_turns, [:user])

  end
end
