defmodule BokerTovNissim.Mixfile do
  use Mix.Project

  def project do
    [
      app: :boker_tov_nissim,
      version: String.trim_trailing(File.read!("VERSION"), "\n"),
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {BokerTovNissim.Application, []},
      extra_applications: [:nadia, :cowboy, :httpoison, :poison, :logger, :gproc, :pid_file, :temp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.4.2"},
      {:httpoison, "~> 0.13.0"},
      {:poison, "~> 3.1"},
      {:cowboy, "~> 2.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:gproc, "~> 0.6.1"},
      {:temp, "~> 0.4.3"},
      {:distillery, "~> 1.5", runtime: false},
      {:pid_file, "~> 0.1.1"},
      {:poolboy, "~> 1.5"}
    ]
  end
end
