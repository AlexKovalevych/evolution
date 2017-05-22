defmodule Evolution.Engine do
  def put_card(fsm, user, card) when is_integer(card), do: :gen_statem.call(fsm, {:create_animal, user, card})

  def put_card(fsm, user, properties), do: :gen_statem.call(fsm, {:put_card, user, properties})

  # add support for cooperation

  # add support for parasite

  def add_player(fsm, user), do: :gen_statem.call(fsm, {:add_player, user})

  def finish_stage(fsm, user), do: :gen_statem.call(fsm, {:finish_stage, user})

  def start_game(fsm), do: :gen_statem.call(fsm, :start)

  def show_current_state(fsm), do: :gen_statem.call(fsm, :show_current_state)
end
