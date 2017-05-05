defmodule Evolution.Engine.Rules do
  @behaviour :gen_statem

  def start_link(game) do
    :gen_statem.start_link(__MODULE__, :initialized, [])
  end

  def init(:ok) do
    {:ok, :initialized, []}
  end
end
