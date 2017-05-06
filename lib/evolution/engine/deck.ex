defmodule Evolution.Engine.Deck do
  @moduledoc """

  :big - большой. Данное существо может быть атаковано только БОЛЬШИМ хищником

  :fat - жировой запас

  :burrow - норное. Когда существо НАКОРМЛЕНО, оно не может быть атаковано хищником

  :mimicry - мимикрия. Когда это существо атаковано хищником, владелец существа должен
  перенаправить атаку хищника на другое свое существо, которое этот хищник способен атаковать

  :hibernation - спячка. Использовать в свою фазу питания - существо считается НАКОРМЛЕННЫМ.
  Это свойство нельзя использовать два хода подряд и в последний ход

  :symbiosis - симбиоз. Сыграть одновременно на пару существ. Одно из существ указывается как
  СИМБИОНТ. Другое существо не может быть атаковано хищником пока жив СИМБИОНТ, но может
  получать :red/:blue только если СИМБИОНТ уже накормлен

  :carrioner - падальщик. Когда съедено другое существо, существо с этим свойством получает
  :blue. :blue может получить только одно существо на столе, начиная с существа игрока,
  которому принадлежит хищник, и далее по часовой стрелке. Это свойство нельзя
  сыграть на существо со свойством ХИЩНИК и наоборот

  :piracy - пиратство. Использовать это свойство в свою фазу питания. Получить :blue, забрав
  один :red/:blue у другого существа на столе, которое уже получало в этот ход :red/:blue,
  но еще не накормлено. Существо может использовать это свойство только один раз за ход

  :tail_casting - отбрасывание хвоста. Когда существо атаковано хищником, поместить в
  сброс карту этого или другого имеющегося у существа свойста. Существо остается в живых.
  Хищник получает только один :blue

  :camouflage - камуфляж. Существо может быть атаковано только хищником, имеющий свойство
  ОСТРОЕ ЗРЕНИЕ

  :parasite - паразит. Может быть сыграно только на существо другого игрока

  :poisonous - ядовитое. Хищник, съевший это существо, в фазу вымирания текущего хода погибает

  :keen_sight - острое зрение. Хищник, имеющий это свойство, может атаковать существо со
  свойством КАМУФЛЯЖ

  :tramper - топотун. Можно использовать в каждую свою фазу питания - уничтожить один :red
  из кормовой базы

  :cooperation - сотрудничество. Сыграть одновременно на пару существ. Когда одно существо получает
  :red/:blue - второе существо сразу же получает один :blue

  :interaction - взаимодействие. Сыграть одновременнл на пару существ. Когда одно существо получает
  :red из кормовой базы, другое существо получает :red вне очереди
  """

  alias Evolution.Game

  @cards [
    {:big, :fat},
    {:burrow, :fat},
    {:mimicry},
    {:big, :predator},
    {:hibernation, :predator},
    {:symbiosis},
    {:carrioner},
    {:piracy},
    {:tail_casting},
    {:camouflage, :fat},
    {:parasite, :fat},
    {:parasite, :predator},
    {:poisonous, :predator},
    {:keen_sight, :fat},
    {:tramper, :fat},
    {:cooperation, :predator},
    {:cooperation, :fat},
    {:interaction, :predator}
  ]

  defstruct pack: [], discard_pile: []

  def new do
    %__MODULE__{
      pack:
        @cards
        |> Stream.cycle()
        |> Stream.take(Enum.count(@cards) * 4)
        |> Enum.to_list
    }
  end

  def shuffle(%__MODULE__{pack: pack} = deck) do
    %__MODULE__{deck | pack: Enum.shuffle(pack)}
  end

  def take_cards(%__MODULE__{pack: pack} = deck, number) when is_integer(number) do
    {cards, tail} = Enum.split(pack, number)
    {cards, %{deck | pack: tail}}
  end

  def load(%Game{deck: deck, discard_pile: discard_pile}) do
    %__MODULE__{
      pack: Enum.map(deck, &from_string/1),
      discard_pile: Enum.map(discard_pile, &from_string/1),
    }
  end

  def save(%__MODULE__{pack: pack, discard_pile: discard_pile} = deck) do
    %{deck: Enum.map(pack, &to_string/1), discard_pile: Enum.map(discard_pile, &to_string/1)}
  end

  def from_string(card) when is_bitstring(card) do
    card
    |> String.split("_")
    |> Enum.map(&String.to_atom/1)
    |> List.to_tuple
  end

  def to_string(card) when is_tuple(card) do
    card
    |> Tuple.to_list
    |> Enum.map(&to_string/1)
    |> Enum.join("_")
  end
end
