defmodule Evolution.Repo.Migrations.CreateUserGameAnimal do
  use Ecto.Migration

  def change do
    create table(:user_game_animals) do
      add :card, :integer
      add :properties, {:array, :string}
      add :food, :integer
      add :extra_food, :integer
      add :fat, :integer
      add :user_game_id, references(:user_games, on_delete: :nothing)
      add :cooperation_id, references(:user_game_animals, on_delete: :nilify_all)
      add :interaction_id, references(:user_game_animals, on_delete: :nilify_all)

      timestamps()
    end

    create index(:user_game_animals, [:user_game_id])
  end
end
