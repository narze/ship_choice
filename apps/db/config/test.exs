use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :db, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/shipchoice_test"

# Uncomment this line to hide database requests when running tests
config :logger, level: :warn
