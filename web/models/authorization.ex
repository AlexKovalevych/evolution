defmodule Evolution.Authorization do
  use Evolution.Web, :model

  schema "authorizations" do
    field :provider, :string
    field :uid, :string
    field :token, :string
    field :expires_at, :integer
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    belongs_to :user, Gt.User

    timestamps()
  end

  @required_fields ~w(provider uid user_id token)a
  @optional_fields ~w(expires_at)a


  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:provider_uid)
  end
end
