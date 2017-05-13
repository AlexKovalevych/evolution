defmodule Evolution.Engine.Rules do
  @behaviour :gen_statem

  alias Evolution.Engine.Deck
  alias Evolution.Game
  alias Evolution.Repo
  alias Evolution.UserGame
  import Ecto.Query

  def start_link(%Game{fsm_state: fsm_state} = game) do
    game = Repo.preload(game, :players)
    state = if is_nil(fsm_state), do: :initialized, else: String.to_atom(fsm_state)
    :gen_statem.start_link(__MODULE__, %{state: state, game: game}, [])
  end

  def init(%{state: state, game: game}) do
    {:ok, state, game}
  end

  def initialized({:call, from}, {:add_player, user}, game) do
    players = Repo.preload(game.players, :user)
    already_added = Enum.any?(players, fn user_game ->
      user_game.user.id == user.id
    end)
    if already_added || game.players_number == Enum.count(players) do
      {:keep_state_and_data, {:reply, from, :error}}
    else
      new_order = game.turn_order ++ [user.id]
      game = %{game | turn_order: new_order}
      %UserGame{}
      |> UserGame.changeset(
        %{
          user_id: user.id,
          game_id: game.id
        }
      )
      |> Repo.insert!
      game = refresh_game(game)
      {:keep_state, game, {:reply, from, game}}
    end
  end

  def initialized({:call, from}, :start, game) do
    game = Repo.transaction(fn ->
      deck = Enum.reduce(game.players, Deck.new |> Enum.shuffle, fn user_game, deck ->
        {cards, deck} = UserGame.take_cards(deck, 6)
        user_game
        |> UserGame.changeset(%{cards: cards})
        |> Repo.update!
        deck
      end)
      game
      |> Game.changeset(
        %{
          fsm_state: "started",
          deck: deck,
          discard_pile: [],
        }
      )
      |> Repo.update!
    end)
    {:next_state, :started, game, {:reply, from, :ok}}
  end

  def initialized({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :initialized}}
  end

  def initialized({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def started({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :started}}
  end

  def started({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def add_player(fsm, user), do: :gen_statem.call(fsm, {:add_player, user})

  def start_game(fsm), do: :gen_statem.call(fsm, :start)

  def show_current_state(fsm), do: :gen_statem.call(fsm, :show_current_state)

  def callback_mode, do: :state_functions

  def code_change(_vsn, state_name, state_data, _extra), do: {:ok, state_name, state_data}

  def terminate(_reason, _state, _data), do: :nothing

  defp refresh_game(game) do
    Game
    |> where([g], g.id == ^game.id)
    |> join(:left, [g], p in assoc(g, :players))
    |> join(:left, [g, p], u in assoc(p, :user))
    |> preload([g, p], [players: p])
    |> Repo.one
  end
end
