# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :web,
  namespace: Web

# Configures the endpoint
config :web, WebWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yfl5ZSKgitstjl8UmGUx6jUbqIN+vMXBvj8YssV3ojqoZvXSTOZl8cFV5c9TZv9B",
  render_errors: [view: WebWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :web,
  ecto_repos: [Db.Repo]

config :phoenix, :generators,
  migration: false

config :phoenix, :generators,
  model: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
