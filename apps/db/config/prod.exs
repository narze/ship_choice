use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :db, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "postgres://localhost/shipchoice_prod"
