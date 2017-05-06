defmodule Evolution.Engine.Game do
  use GenServer
  alias Evolution.Engine.Deck
  alias Evolution.Engine.Player
  alias Evolution.Engine.Rules

  defstruct game: nil, deck: nil, players: %{}, turn_order: [], started: false, fsm: nil

  def start_link(%__MODULE__{game: game} = state) do
    GenServer.start_link(__MODULE__, state, name: {:global, "game:#{game.id}"})
  end

  def start_link(%Game{} = game) do
    GenServer.start_link(__MODULE__, game, name: {:global, "game:#{game.id}"})
  end

  def init(%__MODULE__{game: game} = state) do
    {:ok, fsm} = Rules.start_link(game)
    {:ok, %__MODULE__{state | fsm: fsm}}
  end

  def init(%Game{} = game) do
    {:ok, fsm} = Rules.start_link(game)
    {:ok, %__MODULE__{deck: Deck.new, fsm: fsm, game: game}}
  end

  def add_player(pid, user) do
    GenServer.call(pid, {:add_player, user})
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def get_state(id) do
    pid = {:global, "game:#{id}"}
    if Process.alive?(pid) do
      GenServer.call(pid, :get_state)
    else
      game = Repo.get!(Evolution.Game, id)
      {:ok, pid} = start_link()
    end
  end

  def save(pid) do
    GenServer.call(pid, :save)
  end

  # def load(game) do
  #   start_link(game)
  # end

  def handle_call(:save, _from, state) do
    %{deck: deck, discard_pile: discard_pile} = if is_nil(state.deck) do
      %{deck: [], discard_pile: []}
    else
      Deck.save(state.deck)
    end

    Repo.transaction(fn ->
      state.game
      |> Game.changeset(
        %{
          turn_order: state.turn_order,
          deck: deck,
          discard_pile: discard_pile,
          fsm_state: state.fsm |> Rules.show_current_state |> to_string,
        }
      )
      |> Repo.update!

      # update players
    end)
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
