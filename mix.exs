defmodule Links.Mixfile do
  use Mix.Project

  def project do
    [
      app: :links,
      version: "0.5.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Links.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_ecto, "~> 4.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:cowboy, "~> 2.5"},
      {:distillery, "~> 2.0"},
      {:ecto_sql, "~>3.0"},
      {:postgrex, "~> 0.15"},
      {:httpoison, "~>1.4"},
      {:floki, "~> 0.21.0"},
      {:comeonin, "~> 5.1"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end
end
