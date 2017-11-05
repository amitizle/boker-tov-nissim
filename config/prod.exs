
use Mix.Config

config :boker_tov_nissim,
  env: :prod,
  webserver: %{
    port: 8080
  }

config :pid_file, file: "/var/run/boker_tov_nissim.pid"

config :logger,
  backends: [{LoggerFileBackend, :info}, {LoggerFileBackend, :warn}]

config :logger, :info,
  path: "/var/log/boker_tov_nissim/info.log",
  level: :info

config :logger, :warn,
  path: "/var/log/boker_tov_nissim/warn.log",
  level: :warn
