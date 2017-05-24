defmodule Evolution.Engine.Card do
  # @properties ~w(
  #   big
  #   fat
  #   burrow
  #   mimicry
  #   predator
  #   hibernation
  #   carrioner
  #   piracy
  #   tail_casting
  #   parasite
  #   camouflage
  #   poisonous
  #   keen_sight
  #   tramper
  # )
  # {:symbiosis},
  # {:cooperation}
  # {:interaction}

  def check_property(animal, "big" = property) do
    !Enum.member?(animal.properties, property)
  end


  def check_property(animal, property) do
    # check if user can add this property to animal
  end

  def from_str(card) when is_bitstring(card) do
    card
    |> String.split(" ")
    |> Enum.map(&String.to_atom/1)
    |> List.to_tuple
  end

  def to_str(card) when is_tuple(card) do
    card
    |> Tuple.to_list
    |> Enum.map(&to_string/1)
    |> Enum.join(" ")
  end
end
