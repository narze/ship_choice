use Mix.Config

# Configure your database
config :shipchoice_db, ShipchoiceDb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "shipchoice_db_dev",
  hostname: "localhost",
  pool_size: 10
