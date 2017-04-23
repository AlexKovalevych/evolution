defmodule Evolution.Engine.Game do
  use GenServer
  alias Evolution.Engine.Deck
  alias Evolution.Engine.Player

  defstruct deck: nil, players: %{}, turn_order: []

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    {:ok, %__MODULE__{deck: Deck.new}}
  end

  def add_player(pid, user) do
    GenServer.call(pid, {:add_player, user})
  end

  def start_game(pid) do
    %__MODULE__{players: players} = GenServer.call(pid, :shuffle_deck)
    players
    |> Enum.each(fn {_, player} ->
      GenServer.call(pid, {:take_cards, player, 6})
    end)
  end

  def handle_call({:add_player, user}, _from, %__MODULE__{players: players, turn_order: order} = state) do
    player = %Player{user: user, id: user.id}
    state = %{state | players: Map.put(players, user.id, player), turn_order: order ++ [user.id]}
    {:reply, state, state}
  end

  def handle_call(:shuffle_deck, _from, %__MODULE__{deck: deck} = state) do
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
