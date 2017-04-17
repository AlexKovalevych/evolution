defmodule Evolution.User do
  @moduledoc """
  """

  use Evolution.Web, :model

  schema "users" do
    field :login, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @required_fields ~w(login password)a

  @optional_fields ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    # |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:password, min: 4)
    |> unique_constraint(:login)
  end

end
