use Mix.Config

# Configure your database
config :shipchoice_db, ShipchoiceDb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "shipchoice_db_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 999999

config :bcrypt_elixir, log_rounds: 4

config :logger, level: :error
