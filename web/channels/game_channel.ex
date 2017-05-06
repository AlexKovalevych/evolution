defmodule Evolution.GameChannel do
  use Phoenix.Channel
  alias Evolution.Repo
  alias Evolution.Game
  alias Evolution.Engine.Game, as: GameEngine
  import Guardian.Phoenix.Socket
  import Ecto.Query
  import Ecto.Query.API, only: [fragment: 1]

  def join("games:list", _payload, socket) do
    {:ok, socket}
  end

  # def join(room, _, socket) do
  #   {:error,  :authentication_required}
  # end

  def handle_in("games:new", %{"players" => players}, socket) do
    user = current_resource(socket)
    game = %Game{}
    |> Game.changeset(%{players_number: players, creator_id: user.id})
    |> Repo.insert!
    {:ok, pid} = GameEngine.start_link(game)
    GameEngine.add_player(pid, user)
    state = GameEngine.get_state(pid)
    # broadcast(socket, "new:game", %{game: game})
    {:reply, {:ok, state}, socket}
  end

  def handle_in("games:list", payload, socket) do
    user = current_resource(socket)
    page = user_games(user, payload)
    {:reply, {:ok, %{games: page.entries, total_pages: page.total_pages, page: page.page_number}}, socket}
  end

  def handle_in("games:load", %{"id" => id}, socket) do
    user = current_resource(socket)
    state = GameEngine.get_state({:global, "game:#{id}"})
    {:reply, {:ok, state}, socket}
  end

  def handle_in("games:search", payload, socket) do
    user = current_resource(socket)
    {:reply, {:ok, %{}}, socket}
  end

  def user_games(user, %{"page" => page}) do
    Evolution.Game
    |> join(:left, [g], ug in fragment("SELECT * FROM user_games AS ug WHERE ug.user = ?", ^user.id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)
  end
end
