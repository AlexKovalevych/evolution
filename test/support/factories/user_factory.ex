defmodule Evolution.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Evolution.User{
          login: "admin",
          password: "password"
        }
      end
    end
  end
end
