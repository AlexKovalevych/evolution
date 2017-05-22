defmodule Evolution.Engine.Stage.Evolution do
  alias Evolution.Repo
  alias Evolution.UserGameAnimal
  alias Evolution.Game
  alias Evolution.UserGame

  def create_animal(card, game, user, user_game) do
    user_game = Repo.preload(user_game, :animals)
    player_index = game.stage_order |> Enum.find_index(fn id ->
      id == user.id
    end)
    next_turn_id = Enum.at(game.stage_order, player_index + 1, List.first(game.stage_order))
    Repo.transaction(fn ->
      user_game
      |> UserGame.changeset(%{cards: List.delete_at(user_game.cards, card)})
      |> Repo.update!

      %UserGameAnimal{}
      |> UserGameAnimal.changeset(
        %{
          card: user_game.animals |> Enum.count |> to_string,
          user_game_id: user_game.id,
        }
      )
      |> Repo.insert!

      game
      |> Game.changeset(%{current_turn_id: next_turn_id})
      |> Repo.update!
    end)
  end
end
