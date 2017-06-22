defmodule Evolution.GameChannel do
  use Phoenix.Channel
  alias Evolution.Repo
  alias Evolution.Game
  alias Evolution.Engine.Rules, as: GameEngine
  import Guardian.Phoenix.Socket
  import Ecto.Query
  import Ecto.Query.API, only: [fragment: 1]

  def join("games:list", _payload, socket) do
    {:ok, socket}
  end

  # def join(room, _, socket) do
  #   {:error,  :authentication_required}
  # end

  def handle_in("new", %{"players" => players}, socket) do
    user = current_resource(socket)
    game = %Game{}
    |> Game.changeset(
      %{
        players_number: players,
        creator_id: user.id,
      }
    )
    |> Repo.insert!
    {:ok, pid} = GameEngine.start_link(game)
    # GameEngine.add_player(pid, user)
    # GameEngine.save(pid)
    state = GameEngine.get_state(pid)
    # broadcast(socket, "new:game", %{game: game})
    {:reply, {:ok, state}, socket}
  end

  def handle_in("list", payload, socket) do
    user = current_resource(socket)
    page = user_games(user, payload)
    {:reply, {:ok, %{games: page.entries, total_pages: page.total_pages, page: page.page_number}}, socket}
  end

  def handle_in("load", %{"id" => id}, socket) do
    user = current_resource(socket)
    # state = GameEngine.get_state(id)
    state = %{}
    {:reply, {:ok, state}, socket}
  end

  def handle_in("search", payload, socket) do
    user = current_resource(socket)
    page = search_games(user, payload)
    IO.inspect(page.entries)
    {:reply, {:ok, %{games: page.entries, total_pages: page.total_pages, page: page.page_number}}, socket}
  end

  def user_games(user, %{"page" => page}) do
    Evolution.Game
    |> join(:left, [g], ug in fragment("SELECT * FROM user_games AS ug WHERE ug.user_id = ?", ^user.id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)
  end

  def search_games(user, %{"page" => page, "players" => players, "player" => player}) do
    query = Evolution.Game
    |> where([g], g.players_number == ^players)
    |> where([g], is_nil(g.fsm_state))
    |> join(:left, [g], ug in assoc(g, :players))
    |> join(:left, [g, ug], u in assoc(ug, :user))

    query = if player != "" do
      query
      |> where([g, ug, u], ilike(u.login, ^"%#{player}%"))
    else
      query
    end

    query
    |> group_by([g, ug, u], g.id)
    |> having([g, ug, u], fragment("NOT(? = ANY(array_agg(?))) OR array_agg(?) = ARRAY[NULL]::integer[]",
              ^user.id,
              ug.user_id,
              ug.user_id
              ))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)
  end
end
