defmodule Evolution.Repo.Migrations.CreateUserGameAnimal do
  use Ecto.Migration

  def change do
    create table(:user_game_animals) do
      add :card, :string
      add :properties, {:array, :string}
      add :food, :integer
      add :extra_food, :integer
      add :fat, :integer
      add :user_game, references(:user_games, on_delete: :nothing)
      add :cooperation, references(:user_game_animals, on_delete: :nilify_all)
      add :interaction, references(:user_game_animals, on_delete: :nilify_all)

      timestamps()
    end

    create index(:user_game_animals, [:user_game])
  end
end
