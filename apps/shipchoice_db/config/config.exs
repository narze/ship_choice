use Mix.Config

config :shipchoice_db, ecto_repos: [ShipchoiceDb.Repo]

import_config "#{Mix.env}.exs"
