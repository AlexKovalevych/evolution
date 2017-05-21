defmodule Evolution.Engine.Card do
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
