defmodule Links.Mixfile do
  use Mix.Project

  def project do
    [
      app: :links,
      version: "0.3.5",
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
      applications: [
        :plug_cowboy,
        :poolboy,
        :moebius,
        :poison,
        :httpoison,
        :phoenix_html,
        :phoenix
      ],
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
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:cowboy, "~> 2.5"},
      {:distillery, "~> 2.0"},
      {:moebius, "~>3.0.1"},
      {:poison, "~>3.0.0"},
      {:httpoison, "~> 1.4"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end
end
