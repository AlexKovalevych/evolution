defmodule Evolution.GameChannel do
  use Phoenix.Channel
  alias Evolution.Repo
  import Guardian.Phoenix.Socket
  import Ecto.Query
  import Ecto.Query.API, only: [fragment: 1]

  def join("games:list", %{"page" => page}, socket) do
    user = current_resource(socket)
    page = Evolution.Game
    |> join(:left, [g], ug in fragment("SELECT * FROM user_games AS ug WHERE ug.user = ?", ^user.id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)

    # get user games for page
    {:ok, %{games: page.entries, total_pages: page.total_pages}, socket}
  end

  # def join(room, _, socket) do
  #   {:error,  :authentication_required}
  # end

  # def handle_in("ping", _payload, socket) do
  #   user = current_resource(socket)
  #   broadcast(socket, "pong", %{message: "pong", from: user.email})
  #   {:noreply, socket}
  # end
end
