defmodule Evolution.GameChannel do
  use Phoenix.Channel
  alias Evolution.Repo
  alias Evolution.Game
  import Guardian.Phoenix.Socket
  import Ecto.Query
  import Ecto.Query.API, only: [fragment: 1]

  def join("games:list" = topic, _payload, socket) do
    {:ok, socket}
  end

  # def join(room, _, socket) do
  #   {:error,  :authentication_required}
  # end

  def handle_in("new:game", %{"players" => players}, socket) do
    user = current_resource(socket)
    game = %Game{}
    |> Game.changeset(%{players_number: players})
    |> Repo.insert!
    # broadcast(socket, "new:game", %{game: game})
    {:reply, {:ok, game}, socket}
  end

  def handle_in("games:list", payload, socket) do
    user = current_resource(socket)
    page = user_games(user, payload)
    {:reply, {:ok, %{games: page.entries, total_pages: page.total_pages, page: page.page_number}}, socket}
  end

  def user_games(user, %{"page" => page}) do
    Evolution.Game
    |> join(:left, [g], ug in fragment("SELECT * FROM user_games AS ug WHERE ug.user = ?", ^user.id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)
  end
end
