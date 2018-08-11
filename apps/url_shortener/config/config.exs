# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :url_shortener,
  bitly_group_uuid: System.get_env("BITLY_GROUP_UUID"),
  bitly_access_token: System.get_env("BITLY_ACCESS_TOKEN")

import_config "#{Mix.env}.exs"
