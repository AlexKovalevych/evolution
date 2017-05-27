defmodule Evolution.Engine.RulesTest do
  use Evolution.ModelCase
  import Evolution.Factory

  alias Evolution.Engine
  alias Evolution.Engine.Rules
  alias Evolution.Engine.Card

  defp create_game do
    user1 = insert(:user, %{login: "user1"})
    user2 = insert(:user, %{login: "user2"})
    game = insert(:game, %{creator: user1})
    {user1, user2, game}
  end

  defp start_game do
    {user1, user2, game} = create_game()
    {:ok, pid} = Rules.start_link(game)
    Engine.add_player(pid, user1)
    Engine.add_player(pid, user2)
    {pid, user1, user2, Engine.start_game(pid)}
  end

  test "create a finite state machine" do
    {_, _, game} = create_game()
    {:ok, pid} = Rules.start_link(game)
    assert is_pid(pid)
  end

  test "add players to game" do
    {user1, user2, game} = create_game()
    {:ok, pid} = Rules.start_link(game)
    game = Engine.add_player(pid, user1)
    player = Enum.at(game.players, 0)

    assert Enum.count(game.players) == 1
    assert player.user.id == user1.id
    assert :error = Engine.add_player(pid, user1)

    game = Engine.add_player(pid, user2)

    assert Enum.count(game.players) == 2
    refute is_nil(Enum.find(game.players, &(&1.user.id == user2.id)))
    assert :error = Engine.add_player(pid, user2)
  end

  test "start game" do
    {pid, _, _, game} = start_game()

    assert Enum.count(game.deck) == 60
    assert game.fsm_state == "evolution"
    assert Engine.show_current_state(pid) == :evolution
  end

  test "create animal" do
    {pid, user1, user2, game} = start_game()
    # IO.inspect(game)

    assert Engine.put_card(pid, user1, 10) == "no such card"

    player = Enum.at(game.players, 0)
    assert Enum.count(player.cards) == 6

    game = Engine.put_card(pid, user1, 0)
    player = Enum.find(game.players, &(&1.user.id == user1.id))
    refute is_nil(player)
    animals = player.animals
    assert Enum.count(animals) == 1

    animal = Enum.at(player.animals, 0)
    assert animal.card == 0
    assert Enum.count(player.cards) == 5
    assert Engine.put_card(pid, user1, 0) == "not your turn"

    game = Engine.put_card(pid, user2, 3)
    player = Enum.find(game.players, &(&1.user.id == user2.id))
    refute is_nil(player)
    animals = player.animals
    assert Enum.count(animals) == 1

    animal = Enum.at(player.animals, 0)
    assert animal.card == 0
    assert Enum.count(player.cards) == 5
  end

  test "finish evolution stage" do
    {pid, user1, user2, game} = start_game()
    game = Engine.put_card(pid, user1, 0)
    Engine.put_card(pid, user2, 0)
    game = Engine.finish_stage(pid, user1)
    player = Enum.find(game.players, &(&1.user.id == user1.id))

    refute is_nil(player)
    assert player.finish_stage
    assert Enum.count(player.cards) == 5
    assert "not your turn" == Engine.finish_stage(pid, user1)
    assert game.stage_order == [user2.id]
  end

  test "create animal property" do
    {pid, user1, user2, _} = start_game()
    Engine.put_card(pid, user1, 0)
    game = Engine.put_card(pid, user2, 0)
    card = game.players
    |> Enum.at(0)
    |> Map.get(:cards)
    |> Enum.at(0)
    |> Card.from_str
    |> Tuple.to_list
    |> List.first
    |> to_string
    game = Engine.put_card(pid, user1, {0, card, 0})
    IO.inspect(game)
  end
end
