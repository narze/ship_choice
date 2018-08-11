# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :url_shortener,
  bitly_group_guid: System.get_env("BITLY_GROUP_GUID"),
  bitly_access_token: System.get_env("BITLY_ACCESS_TOKEN")

import_config "#{Mix.env}.exs"
