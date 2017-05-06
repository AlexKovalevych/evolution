defmodule Evolution.Engine.Game do
  use GenServer
  alias Evolution.Engine.Deck
  alias Evolution.Engine.Player
  alias Evolution.Engine.Rules

  defstruct game: nil, deck: nil, players: %{}, turn_order: [], started: false, fsm: nil

  def start_link(game) do
    GenServer.start_link(__MODULE__, game, name: {:global, "game:#{game.id}"})
  end

  def init(game) do
    {:ok, fsm} = Rules.start_link(game)
    {:ok, %__MODULE__{deck: Deck.new, fsm: fsm, game: game}}
  end

  def add_player(pid, user) do
    GenServer.call(pid, {:add_player, user})
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Nothing to do if game is started
  """
  def handle_call(:start_game, _from, %__MODULE__{started: true} = state) do
    {:reply, state, state}
  end

  @doc """
  Shuffle a deck, give players first cards and start a game
  """
  def handle_call(:start_game, _from, %__MODULE__{players: players, started: false} = state) do
    state = [
      GenServer.call(self(), :shuffle_deck) |
      players
      |> Enum.map(fn {_, player} ->
        GenServer.call(self(), {:take_cards, player, 6})
      end)
    ]
    |> List.last
    state = %{state | started: true}
    {:reply, state, state}
  end

  @doc """
  Add player to game which is not yet started
  """
  def handle_call(
    {:add_player, user},
    _from,
    %__MODULE__{players: players, turn_order: order, started: false} = state
  ) do
    player = %Player{user: user, id: user.id}
    new_order = if Map.has_key?(players, user.id), do: order, else: order ++ [user.id]
    state = %{state |
              players: Map.put(players, user.id, player),
              turn_order: new_order
             }
    {:reply, state, state}
  end

  def handle_call({:add_player, _}, _from, %__MODULE__{started: true} = state) do
    {:reply, state, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, %{
        players: Map.values(state.players),
        state: Rules.show_current_state(state.fsm),
        game: state.game
     }, state}
  end

  @doc """
  We can shuffle deck only before game is started
  """
  def handle_call(:shuffle_deck, _from, %__MODULE__{deck: deck, started: false} = state) do
    state = %{state | deck: Deck.shuffle(deck)}
    {:reply, state, state}
  end

  def handle_call({:take_cards, player, number}, _from, %__MODULE__{deck: deck, players: players} = state) do
    {cards, deck} = Deck.take_cards(deck, number)
    player = Player.add_cards(player, cards)
    state = %{state | deck: deck, players: Map.put(players, player.id, player)}
    {:reply, state, state}
  end
end
