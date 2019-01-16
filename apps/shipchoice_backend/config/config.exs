# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :shipchoice_backend,
  namespace: ShipchoiceBackend

# Configures the endpoint
config :shipchoice_backend, ShipchoiceBackend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nbbwuBjnleEmwbeF/zYR7Vt43z33FAuhmiLjLOAB2rL19duJ36TQp9JcS0IglH1Y",
  render_errors: [view: ShipchoiceBackend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ShipchoiceBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :shipchoice_backend, :generators,
  context_app: :shipchoice_backend

config :scrivener_html,
  routes_helper: MyApp.Router.Helpers,
  view_style: :bootstrap_v4

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
