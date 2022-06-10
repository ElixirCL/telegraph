defmodule Telegraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegraph,
      version: "1.0.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Telegraph.CLI]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"}
    ]
  end
end
