defmodule Evolution.Repo.Migrations.CreateUserGame do
  use Ecto.Migration

  def change do
    create table(:user_games) do
      add :cards, {:array, :string}, null: false
      add :game_id, references(:games, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_games, [:game_id])
  end
end
