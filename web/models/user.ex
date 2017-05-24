defmodule Evolution.User do
  @derive {Poison.Encoder, only: [:id, :login]}

  use Evolution.Web, :model
  alias Evolution.Authorization
  import Ecto.Query
  import Evolution.Gettext

  schema "users" do
    field :login, :string
    field :password, :string, virtual: true

    has_many :authorizations, Authorization, on_replace: :delete

    many_to_many :games, Evolution.Game, join_through: "user_games"

    timestamps()
  end

  @required_fields ~w(login)a

  @optional_fields ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    # |> validate_confirmation(:password)
    |> validate_length(:login, min: 4)
    # |> validate_length(:password, min: 4)
    |> unique_constraint(:login)
  end

  def registration_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(login)a)
    |> validate_required(@required_fields)
  end
end
