defmodule Evolution.User do
  use Evolution.Web, :model

  schema "users" do
    field :login, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:login])
    |> validate_required([:login])
  end
end
