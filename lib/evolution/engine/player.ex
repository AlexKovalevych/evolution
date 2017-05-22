defmodule Evolution.Engine.Player do
  def check_turn(game, user) do
    player = game.players
    |> Enum.find(fn user_game ->
      user_game.user_id == user.id && !user_game.finish_stage
    end)
    with {true, _} <- {user.id == game.current_turn.id, "not your turn"},
         {true, _} <- {!is_nil(player), "invalid user id"} do
       {true, player}
    else
      {false, reason} -> {false, reason}
    end
  end
end
