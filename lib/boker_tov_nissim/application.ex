defmodule BokerTovNissim.Application do
  use Application
  require Logger

  def start(_type, _args) do
    port = BokerTovNissim.Config.get([:webserver, :port])
    { :ok, _ } = :cowboy.start_clear(:http, [{:port, port}], %{env: %{dispatch: dispatch_config()}})
    set_webhook()
    import Supervisor.Spec
    children = [
      supervisor(BokerTovNissim.Supervisor, [])
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  def dispatch_config do
    :cowboy_router.compile([
      {:_, [{"/", BokerTovNissim.WebServer.BotHandler, []}]}
    ])
  end

  defp set_webhook do
    Logger.info("setting webhook")
    enabled = BokerTovNissim.Config.get([:webhook, :enabled], false)
    set_webhook(enabled)
  end


  defp set_webhook(true) do
    request_webhook_config = [
      url: BokerTovNissim.Config.get([:webhook, :url], "") # TODO allowed_updates, max_connections, certificate
    ]
    Logger.info("setting webhook (enabling) with config #{inspect request_webhook_config}")
    Nadia.set_webhook(request_webhook_config)
  end

  defp set_webhook(_) do
    Logger.info("removing webhook url")
    Nadia.set_webhook()
  end

end

