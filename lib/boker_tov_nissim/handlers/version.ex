defmodule BokerTovNissim.Handlers.Version do
  use GenServer
  require BokerTovNissim.PubSub
  alias BokerTovNissim.PubSub
  require Logger

  @server :version
  @response_probability 1.0

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  # Callbacks

  def init(_args) do
    PubSub.subscribe_to(:command)
    regex = ~r/^version$/iu
    app_version = BokerTovNissim.Config.get_app_version()
    Logger.info("[#{@server}] booting with app_version=#{app_version}")
    {:ok, %{regex: regex, app_version: app_version}}
  end

  def handle_info({:message, message}, %{regex: regex, app_version: app_version} = state) do
    # TODO extract message to it's module or struct
    case Regex.match?(regex, message["text"]) do
      true ->
        send_text(app_version, message)
      _ ->
        :ok
    end
    {:noreply, state}
  end

  defp send_text(text, message) do
    chat_id = message["chat"]["id"] # TODO
    BokerTovNissim.Messenger.send_text(chat_id, text, @response_probability)
  end
end
