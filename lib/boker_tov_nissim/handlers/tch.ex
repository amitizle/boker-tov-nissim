defmodule BokerTovNissim.Handlers.Tch do
  use GenServer
  require BokerTovNissim.PubSub
  alias BokerTovNissim.PubSub
  require Logger

  @server :tch
  @response_probability 1.0

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  # Callbacks

  def init(_args) do
    PubSub.subscribe_to(:text)
    regex = ~r/\b(ט+ח+)\b/miu
    {:ok, %{regex: regex}}
  end

  def handle_info({:message, message}, %{regex: regex} = state) do
    # TODO extract message to it's module or struct
    case Regex.match?(regex, message["text"]) do
      true ->
        send_text(response(message["text"], regex), message)
      _ ->
        :ok
    end
    {:noreply, state}
  end


  defp response(text, regex) do
    Regex.replace(regex, text, fn(_, match) ->
      BokerTovNissim.Utils.replace_occurences(regex, match, %{~r/ט/ => "פ", ~r/ח/ => "ף"})
    end)
  end

  defp send_text(text, message) do
    chat_id = message["chat"]["id"] # TODO
    BokerTovNissim.Messenger.send_text(chat_id, text, @response_probability)
  end
end
