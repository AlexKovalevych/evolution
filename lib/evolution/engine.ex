defmodule Evolution.Engine do
  def put_card(fsm, user, card) when is_integer(card), do: :gen_statem.call(fsm, {:create_animal, user, card})

  def put_card(fsm, user, {from_index, property, to_index})
  when is_integer(from_index) and is_binary(property) and is_integer(to_index) do
    :gen_statem.call(fsm, {:put_card, user, {from_index, property, to_index}})
  end

  def put_card(fsm, user, properties), do: :gen_statem.call(fsm, {:put_card, user, properties})

  # add support for cooperation

  # add support for parasite

  def add_player(fsm, user), do: :gen_statem.call(fsm, {:add_player, user})

  def finish_stage(fsm, user), do: :gen_statem.call(fsm, {:finish_stage, user})

  def start_game(fsm), do: :gen_statem.call(fsm, :start)

  def show_current_state(fsm), do: :gen_statem.call(fsm, :show_current_state)
end
