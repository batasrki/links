use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :links, LinksWeb.Endpoint,
  http: [port: 4001],
  server: false,
  secret_key_base: "Qd+FSVTkEq1L+qxuO6pKTFzZ9jb4ho94F7ZJGmNfvtz9okdCTvpiga9aGVAVDzbs",
  pubsub: [
    adapter: Phoenix.PubSub.PG2,
    pool_size: 1,
    name: Links.PubSub
  ]

# Print only warnings and errors during test
config :logger, level: :warn

config :links, Links.Repo,
  database: "links_repo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

if System.get_env("GITHUB_ACTIONS") do
  config :links, Links.Repo,
    username: "postgres",
    password: "postgres"
else
  config :links, Links.Repo,
    username: "srdjan",
    password: "srkijevo"
end

config :links, ecto_repos: [Links.Repo]
config :links, Links.Mailer, adapter: Bamboo.LocalAdapter
config :links, login_request_salt: "this is a salt! use it carefully?"
