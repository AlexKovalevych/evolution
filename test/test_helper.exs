ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Evolution.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Evolution.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Evolution.Repo)

