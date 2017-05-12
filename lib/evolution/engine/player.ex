defmodule Evolution.Engine.Player do
  @moduledoc """
  id - user id
  animals - user creatures with their properties
  cards - user cards (on hand)
  """

  alias Evolution.Engine.Card

  # defstruct id: nil, user: nil, animals: [], cards: []

  # @derive {Poison.Encoder, only: [:user, :animals]}

  # def add_cards(%__MODULE__{cards: cards} = player, new_cards) do
  #   %__MODULE__{cards: cards ++ new_cards}
  # end

  # def load(%UserGame{deck: deck, discard_pile: discard_pile}) do
  #   %__MODULE__{
  #     pack: Enum.map(deck, &Card.from_string/1),
  #     discard_pile: Enum.map(discard_pile, &Card.from_string/1),
  #   }
  # end

  # def save(%__MODULE__{user: user, animals: animals, cards: cards} = player) do
  #   %{user: user, cards: Enum.map(cards, &Card.to_string/1)}
  # end
end
