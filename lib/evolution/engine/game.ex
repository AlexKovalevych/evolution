defmodule Evolution.Engine.Game do
  use GenServer
  alias Evolution.Engine.Deck
  alias Evolution.Engine.Player
  alias Evolution.Engine.Rules
  alias Evolution.Game, as: GameModel
  alias Evolution.UserGame

  # defstruct game: nil, deck: nil, players: %{}, turn_order: [], started: false, fsm: nil

  # def start_link(%__MODULE__{game: game} = state) do
  #   GenServer.start_link(__MODULE__, state, name: {:global, "game:#{game.id}"})
  # end

  def start_link(%GameModel{} = game) do
    GenServer.start_link(__MODULE__, game, name: {:global, "game:#{game.id}"})
  end

  # def init(%__MODULE__{game: game} = state) do
  #   {:ok, fsm} = Rules.start_link(game)
  #   {:ok, %__MODULE__{state | fsm: fsm}}
  # end

  def init(%GameModel{} = game) do
    {:ok, fsm} = Rules.start_link(game)
    game = %{game | fsm_state: Rules.show_current_state(fsm)}
    {:ok, %{fsm: fsm, game: game}}
  end

  def add_player(pid, user) do
    GenServer.call(pid, {:add_player, user})
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  # def get_state(id) do
  #   pid = {:global, "game:#{id}"}
  #   if Process.alive?(pid) do
  #     GenServer.call(pid, :get_state)
  #   else
  #     game = Repo.get!(GameModel, id)
  #     {:ok, pid} = start_link()
  #   end
  # end

  def save(pid, is_new \\ false) do
    GenServer.call(pid, {:save, is_new})
  end

  # def load(game) do
  #   start_link(game)
  # end

  # def handle_call(:save_new, _from, state) do
  #   %{deck: deck, discard_pile: discard_pile} = if is_nil(state.deck) do
  #     %{deck: [], discard_pile: []}
  #   else
  #     Deck.save(state.deck)
  #   end

  #   Repo.transaction(fn ->
  #     game = state.game
  #     |> Game.changeset(
  #       %{
  #         turn_order: state.turn_order,
  #         deck: deck,
  #         discard_pile: discard_pile,
  #         fsm_state: state.fsm |> Rules.show_current_state |> to_string,
  #       }
  #     )
  #     |> Repo.insert!

  #   end)
  # end

  def handle_call({:save, is_new}, _from, state) do
    %{deck: deck, discard_pile: discard_pile} = if is_nil(state.deck) do
      %{deck: [], discard_pile: []}
    else
      Deck.save(state.deck)
    end

    Repo.transaction(fn ->
      game = state.game
      |> Game.changeset(
        %{
          turn_order: state.turn_order,
          deck: deck,
          discard_pile: discard_pile,
          fsm_state: state.fsm |> Rules.show_current_state |> to_string,
        }
      )
      # |> Repo.update!

      Enum.each(state.players, fn player ->
        %{user: user, cards: cards} = Player.save(player)
        %UserGame{}
        |> UserGame.changeset(
          %{
              cards: cards,
              user_id: user,
              game_id: game.id,
          })
        |> Repo.insert!
      end)
    end)
  end

  @doc """
  Nothing to do if game is started
  """
  # def handle_call(:start_game, _from, %__MODULE__{started: true} = state) do
  #   {:reply, state, state}
  # end

  @doc """
  Shuffle a deck, give players first cards and start a game
  """
  # def handle_call(:start_game, _from, %__MODULE__{players: players, started: false} = state) do
  #   state = [
  #     GenServer.call(self(), :shuffle_deck) |
  #     players
  #     |> Enum.map(fn {_, player} ->
  #       GenServer.call(self(), {:take_cards, player, 6})
  #     end)
  #   ]
  #   |> List.last
  #   state = %{state | started: true}
  #   {:reply, state, state}
  # end

  @doc """
  1. Preload players and their users
  2. Check rules if its allowed to add a new player
  3. Add new player, save it, update order and game
  Add player to game which is not yet started
  """
  def handle_call({:add_player, user}, _from, %{game: game, fsm: fsm} = state) do
    players = Repo.preload(game.players, :user)
    already_added = Enum.any?(players, fn user_game ->
      user_game.user.id == user.id
    end)
    new_order = if already_added, do: game.turn_order, else: game.turn_order ++ [user.id]
    game = %{game | turn_order: new_order}
    user_game = %UserGame{}
    {:reply, state, state}
  end

  # def handle_call({:add_player, _}, _from, %__MODULE__{started: true} = state) do
  #   {:reply, state, state}
  # end

  def handle_call(:get_state, _from, state) do
    {:reply, %{
        state: Rules.show_current_state(state.fsm),
        game: state.game
     }, state}
  end

  @doc """
  We can shuffle deck only before game is started
  """
  # def handle_call(:shuffle_deck, _from, %__MODULE__{deck: deck, started: false} = state) do
  #   state = %{state | deck: Deck.shuffle(deck)}
  #   {:reply, state, state}
  # end

  # def handle_call({:take_cards, player, number}, _from, %__MODULE__{deck: deck, players: players} = state) do
  #   {cards, deck} = Deck.take_cards(deck, number)
  #   player = Player.add_cards(player, cards)
  #   state = %{state | deck: deck, players: Map.put(players, player.id, player)}
  #   {:reply, state, state}
  # end
end
