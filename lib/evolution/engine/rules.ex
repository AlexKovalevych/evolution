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
  alias Evolution.Engine.Player
  alias Evolution.Engine.Card
  import Evolution.Engine.Stage.Evolution, only: [create_animal: 4]
  import Ecto.Query
  require Logger

  def start_link(%Game{fsm_state: fsm_state} = game) do
    game = Game.refresh_game(game)
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
      %UserGame{}
      |> UserGame.changeset(
        %{
          user_id: user.id,
          game_id: game.id
        }
      )
      |> Repo.insert!
      game
      |> Game.changeset(%{turn_order: new_order})
      |> Repo.update!
      game = Game.refresh_game(game)
      {:keep_state, game, {:reply, from, game}}
    end
  end

  def initialized({:call, from}, :start, game) do
    if Enum.count(game.players) == game.players_number do
      transaction = Repo.transaction(fn ->
        players = Repo.preload(game.players, :user)
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
            fsm_state: "evolution",
            deck: deck,
            discard_pile: [],
            stage_order: game.turn_order,
            current_turn_id: List.first(game.turn_order),
          }
        )
        |> Repo.update!
      end)
      case transaction do
        {:ok, game} ->
          game = Game.refresh_game(game)
          {:next_state, :evolution, game, {:reply, from, game}}
        {:error, value} ->
          Logger.error(value)
          {:keep_state_and_data, {:reply, from, :error}}
      end
    else
      {:keep_state_and_data, {:reply, from, :error}}
    end
  end

  def initialized({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :initialized}}
  end

  def initialized({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def evolution({:call, from}, {:put_card, user, {from_index, property, to_index}}, game) do
    with {true, player} <- Player.check_turn(game, user),
         {true, _} <- {!is_nil(Enum.at(player.cards, from_index)), "no such card"},
         {true, _} <- {!is_nil(find_card_property(player, to_index, property)), "no such property"},
         {true, _} <- Card.check_property(Enum.find(player.animals, &(&1.card == to_index)), property),
         {true, _} <- add_property(Enum.find(player.animals, &(&1.card == to_index), property)),
         game <- Game.refresh_game(game) do
      {:keep_state, game, {:reply, from, game}}
    else
      {false, reason} -> {:keep_state_and_data, {:reply, from, reason}}
    end
  end

  defp add_property(animal, property) do
    animal
    |> UserGameAnimal.changeset(%{properties: animal.properties ++ [property]})
    |> Repo.update!
  end

  defp find_card_property(player, index, property) do
    card = player.cards |> Enum.at(index)
    if is_nil(card) do
      false
    else
      card |> String.split(" ") |> Enum.member?(property)
    end
  end

  def evolution({:call, from}, {:put_card, user, _}, game), do: {:keep_state_and_data, {:reply, from, :error}}

  def evolution({:call, from}, {:create_animal, user, card}, game) do
    with {true, player} <- Player.check_turn(game, user),
         {true, _} <- {!is_nil(Enum.at(player.cards, card)), "no such card"},
         {:ok, game} <- create_animal(card, game, user, player),
         game <- Game.refresh_game(game) do
      {:keep_state, game, {:reply, from, game}}
    else
      {false, reason} -> {:keep_state_and_data, {:reply, from, reason}}
      {:error, reason} -> {:keep_state_and_data, {:reply, from, {:error, reason}}}
    end
  end

  def evolution({:call, from}, :show_current_state, _state_data) do
    {:keep_state_and_data, {:reply, from, :evolution}}
  end

  def evolution({:call, from}, {:finish_stage, user}, game) do
    with {true, player} <- Player.check_turn(game, user),
         {:ok, game} <- finish_user_stage(game, player),
         game <- Game.refresh_game(game) do
      {:keep_state, game, {:reply, from, game}}
    else
      {false, reason} -> {:keep_state_and_data, {:reply, from, reason}}
    end
  end

  def evolution({:call, from}, _, _state_data) do
    {:keep_state_and_data, {:reply, from, :error}}
  end

  def callback_mode, do: :state_functions

  def code_change(_vsn, state_name, state_data, _extra), do: {:ok, state_name, state_data}

  def terminate(_reason, _state, _data), do: :nothing

  defp finish_user_stage(game, user_game) do
    player_index = game.stage_order |> Enum.find_index(fn id ->
      id == user_game.user.id
    end)
    next_turn_id = Enum.at(game.stage_order, player_index + 1, List.first(game.stage_order))
    Repo.transaction(fn ->
      user_game
      |> UserGame.changeset(%{finish_stage: true})
      |> Repo.update!

      game
      |> Game.changeset(
        %{
          current_turn_id: next_turn_id,
          stage_order: List.delete_at(game.stage_order, player_index)
        }
      )
      |> Repo.update!
    end)
  end
end
