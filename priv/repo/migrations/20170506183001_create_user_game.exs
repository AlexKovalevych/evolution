defmodule Evolution.Repo.Migrations.CreateUserGame do
  use Ecto.Migration

  def change do
    create table(:user_games) do
      add :cards, {:array, :string}
      add :game, references(:games, on_delete: :nothing)
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_games, [:game])
  end
end
