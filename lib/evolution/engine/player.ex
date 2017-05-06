defmodule Evolution.Engine.Player do
  @moduledoc """
  id - user id
  animals - user creatures with their properties
  cards - user cards (on hand)
  """

  defstruct id: nil, user: nil, animals: [], cards: []

  @derive {Poison.Encoder, only: [:user, :animals]}

  def add_cards(%__MODULE__{cards: cards} = player, new_cards) do
    %__MODULE__{cards: cards ++ new_cards}
  end
end
