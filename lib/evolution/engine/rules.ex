defmodule Evolution.Engine.Rules do
  @behaviour :gen_statem

  @moduledoc """
  Stage 1: Evolution
  Stage 2: Define base
  Stage 3: Food
  Stage 4: Extinction
  """

  alias Evolution.Engine.Deck
  alias Evolution.Game
  alias Evolution.Repo
  alias Evolution.UserGame
  alias Evolution.UserGameAnimal
  import Ecto.Query

  def start_link(%Game{fsm_state: fsm_state} = game) do
    game = Repo.preload(game, [:players, :current_turn])
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
      players = Repo.preload(game.players, :user)
      turn_order = Enum.map(players, fn user_game -> user_game.user.id end)
      deck = Enum.reduce(game.players, Deck.new |> Enum.shuffle, fn user_game, deck ->
        {cards, deck} = UserGame.take_cards(deck, 6)
        user_game
        |> UserGame.changeset(%{cards: cards})
        |> Repo.update!
        deck
      end)
      first_player = players |> List.first
      game
      |> Game.changeset(
        %{
          fsm_state: "evolution",
          deck: deck,
          discard_pile: [],
          turn_order: turn_order,
          stage_order: turn_order,
          current_turn_id: first_player.user.id,
        }
      )
      |> Repo.update!
      |> Repo.preload(:current_turn)
    end)
    {:next_state, :evolution, game, {:reply, from, :ok}}
  end

  def initialized({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :initialized}}
  end

  def initialized({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def evolution({:call, from}, {:put_card, user, {from_index, property, to_index}}, game) do
    player = game.players |> Enum.find(fn user_game ->
      user_game.id == user.id
    end)
    card = Enum.at(player.cards, from_index)
    with true <- user.id != game.current_turn.id,
         true <- !is_nil(player),
         true <- !is_nil(card),
         true <- card |> String.split("_") |> Enum.member?(property) do
      # define if user can put the card at that position
      {:keep_state_and_data, {:reply, from, :ok}}
    else
      false -> {:keep_state_and_data, {:reply, from, :error}}
    end
  end

  def evolution({:call, from}, {:create_animal, user, card}, game) do
    player = game.players |> Enum.find(fn user_game ->
      user_game.id == user.id
    end)
    with true <- user.id != game.current_turn.id,
         true <- !is_nil(player),
         true <- !is_nil(Enum.at(player.cards, card)),
         {:ok, animal} <- create_animal(card, game, user, player) do
      {:keep_state_and_data, {:reply, from, :ok}}
    else
      false -> {:keep_state_and_data, {:reply, from, :error}}
    end
  end

  def evolution({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :evolution}}
  end

  def evolution({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def put_card(fsm, user, card) when is_integer(card), do: :gen_statem.call(fsm, {:create_animal, user, card})

  def put_card(fsm, user, {from_index, property, to_index})
  when is_integer(from_index) and is_binary(property) and is_integer(to_index) do
    :gen_statem.call(fsm, {:put_card, user, {from_index, property, to_index}})
  end

  # add support for cooperation

  # add support for parasite

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

  defp create_animal(card, game, user, user_game) do
    animals = Repo.preload(user_game, :animals)
    new_cards = List.delete_at(user_game.cards, card)
    player_index = game.stage_order |> Enum.find_index(fn id ->
      id == user.id
    end)
    next_turn_id = Enum.at(game.stage_order, List.first(game.stage_order), player_index + 1)
    Repo.transaction(fn ->
      game
      |> Game.changeset(
        %{
          current_turn_id: next_turn_id
        }
      )
      |> Repo.update!

      %UserGameAnimal{}
      |> UserGameAnimal.changeset(
        %{
          card: Enum.count(animals),
          user_game_id: user_game.id,
        }
      )
      |> Repo.insert
    end)
  end
end
