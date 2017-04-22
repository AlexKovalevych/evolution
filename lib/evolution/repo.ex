defmodule Evolution.Repo do
  use Ecto.Repo, otp_app: :evolution
  use Scrivener, page_size: 10
end
