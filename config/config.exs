# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :links, Links.Repo,
  hostname: "localhost",
  username: "srdjan",
  password: "srkijevo",
  database: "links_repo",
  port: 5432,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

config :links, ecto_repos: [Links.Repo]

config :phoenix, :json_library, Jason
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
