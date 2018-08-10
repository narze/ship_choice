# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

config :shipchoice_db, ecto_repos: [ShipchoiceDb.Repo]

config :sentry, dsn: "https://7c5a8f264ec446758d89e30b992bcd53@sentry.io/1259500",
   included_environments: [:prod, :dev],
   environment_name: Mix.env
