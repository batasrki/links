use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :links, LinksWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# TODO add Redis connection here

config :moebius,
  connection: [
    hostname: "localhost",
    username: "srdjan",
    password: "srkijevo",
    database: "links_repo_test"
  ]
