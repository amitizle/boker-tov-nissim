# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
config :boker_tov_nissim,
  subscription_topics: %{
    text: :text_message,
    command: :command_message,
    audio: :audio_message,
    voice: :voice_message
  },
  webhook: %{ # https://core.telegram.org/bots/api#setwebhook
    enabled: true,
    url: {:system, "WEBHOOK_URL"}, # mandatory
    certificate: nil, # optional
    max_connections: nil, # optional
    allowed_updates: nil, # optional
  }

config :nadia,
  token: {:system, "TELEGRAM_BOT_TOKEN"}

config :logger,
  backends: [{LoggerFileBackend, :info}, {LoggerFileBackend, :debug}]

config :logger, :info,
  path: "log/bot.log",
  level: :info

config :logger, :debug,
  path: "log/bot_debug.log",
  level: :debug

import_config "#{Mix.env}.exs"
