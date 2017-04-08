defmodule Evolution.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :login, :string

      timestamps()
    end

  end
end
