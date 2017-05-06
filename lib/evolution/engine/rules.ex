defmodule Evolution.Engine.Rules do
  @behaviour :gen_statem

  alias Evolution.Engine.Rules

  def start_link(game) do
    :gen_statem.start_link(__MODULE__, %{state: :initialized, game: game}, [])
  end

  def init(state_data) do
    {:ok, :initialized, state_data}
  end

  def initialized({:call, from}, {:add_player, player}, state_data) do
    {:next_state, :players_set, %{state_data | players: 2}, {:reply, from, :ok}}
  end

  def initialized({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :initialized}}
  end

  def initialized({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def players_set({:call, from}, {:add_player, player}, state_data) do
    case state_data.players < state_data.game.required_players do
      true -> {:keep_state, %{state_data | players: state_data.players + 1}, {:reply, from, :initialized}}
      false -> {:keep_state_and_data, {:reply, from, :error}}
    end
  end

  def show_current_state(fsm), do: :gen_statem.call(fsm, :show_current_state)

  def callback_mode, do: :state_functions

  def code_change(_vsn, state_name, state_data, _extra), do: {:ok, state_name, state_data}

  def terminate(_reason, _state, _data), do: :nothing
end
