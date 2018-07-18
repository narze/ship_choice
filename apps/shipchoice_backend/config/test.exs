use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shipchoice_backend, ShipchoiceBackend.Endpoint,
  http: [port: 4001],
  server: false

config :bcrypt_elixir, log_rounds: 4

config :logger, level: :error
