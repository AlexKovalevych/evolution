defmodule Evolution.Repo.Migrations.CreateGameUser do
  use Ecto.Migration

  def change do
    create table(:game_users) do
      add :game, references(:games, on_delete: :nothing)
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:game_users, [:game])
    create index(:game_users, [:user])

  end
end
