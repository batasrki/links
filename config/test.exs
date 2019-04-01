use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :links, LinksWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :exredis,
  url: "redis://127.0.0.1:6379/10",
  reconnect: :no_reconnect,
  max_queue: :infinity

config :moebius,
  connection: [
    hostname: "localhost",
    username: "srdjan",
    password: "srkijevo",
    database: "links_repo_test"
  ]
