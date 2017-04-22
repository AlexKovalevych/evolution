defmodule Evolution.Repo.Migrations.CreateUserGame do
  use Ecto.Migration

  def change do
    create table(:user_games, primary_key: false) do
      add :game, references(:games, on_delete: :nothing)
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:user_games, [:game])
    create index(:user_games, [:user])

  end
end
