# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :evolution, Evolution.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "sHm4hiFADnbA3/Hes8CDkjTHYEO8RnmTxg+lbC9l4gnjdR+6C62Duc++7jCYdlSG",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Evolution.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :evolution, ecto_repos: [Evolution.Repo]

config :ueberauth, Ueberauth,
  providers: [
    identity: { Ueberauth.Strategy.Identity, [
                  callback_methods: ["POST"],
                  uid_field: :login,
                  nickname_field: :login,
                ] },
  ]

config :guardian, Guardian,
       hooks: GuardianDb,
       allowed_algos: ["HS512"], # optional
       verify_module: Guardian.JWT,  # optional
       issuer: "Evolution",
       ttl: { 30, :days },
       allowed_drift: 2000,
       verify_issuer: true, # optional
       secret_key: "e03vun495gvye4",
       serializer: Evolution.GuardianSerializer

config :guardian_db, GuardianDb,
       repo: Evolution.Repo,
       schema_name: "guardian_tokens",
       sweep_interval: 120

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: [
    %Rule.LineLength{ max_length: 120 },
    %Rule.ModuleDoc{}
]
