
use Mix.Config

config :boker_tov_nissim,
  env: :dev,
  webserver: %{
    port: 8080
  }

config :pid_file, file: "boker_tov_nissim.pid"
