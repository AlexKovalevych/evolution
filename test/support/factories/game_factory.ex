defmodule Evolution.GameFactory do
  defmacro __using__(_opts) do
    quote do
      def game_factory do
        %Evolution.Game{
          completed: false,
          players_number: 2,
        }
      end
    end
  end
end
