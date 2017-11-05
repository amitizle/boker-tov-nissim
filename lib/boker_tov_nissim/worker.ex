defmodule BokerTovNissim.Worker do
  use GenServer
  require BokerTovNissim.PubSub
  alias BokerTovNissim.PubSub
  require Logger

  @server :bot_worker

  def process_message(message) do
    GenServer.cast(@server, {:process_message, message})
  end

  # GenServer
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  # Callbacks

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast({:process_message, %{"message" => message, "update_id" => update_id}}, state) do
    Logger.debug("[#{update_id}] processing update")
    # Assuming that a message can have more than one type, for example,
    # photo + caption (=> photo + text).
    # Also, we want to send different types to edited messages, forwarded messages
    # etc.
    types = message_types(message)
    Logger.debug("[#{update_id}] message_types=#{inspect types}")
    Enum.each(types, fn(type) -> GenServer.cast(@server, {:process_message, type, update_id, message}) end)
    {:noreply, state}
  end

  def handle_cast({:process_message, :text, update_id, %{"text" => message_text} = message}, state) do
    Logger.debug("[#{update_id}] processing text message")
    Logger.info("Message TEXT: #{message_text}")
    case String.starts_with?(message_text, "/") do
      true ->
        extracted_regex = Regex.named_captures(~r/\/(?<command>[\w\d]+)\@?[\w\d]*/, message_text)
        new_message = Map.put(message, "text", extracted_regex["command"])
        publish_message(new_message, update_id, :command)
      _else -> publish_message(message, update_id, :text)
    end
    {:noreply, state}
  end

  # TODO
  def handle_cast({:process_message, :audio, update_id, _message}, state) do
    Logger.debug("[#{update_id}] processing audio message")
    Logger.warn("bot is not yet supporting audio messages")
    {:noreply, state}
  end
  def handle_cast({:process_message, :photo, update_id, _message}, state) do
    Logger.debug("[#{update_id}] processing photo message")
    Logger.warn("bot is not yet supporting photo messages")
    {:noreply, state}
  end

  def handle_cast({:process_message, :voice, update_id, _message}, state) do
    Logger.debug("[#{update_id}] processing voice message")
    Logger.warn("bot is not yet supporting voice messages")
    {:noreply, state}
  end

  def handle_cast({:process_message, :document, update_id, _message}, state) do
    Logger.debug("[#{update_id}] processing document message")
    Logger.warn("bot is not yet supporting document messages")
    {:noreply, state}
  end

  # TODO maybe `inline_query` and `chosen_inline_query`.
  # TODO maybe `callback_query`

  def handle_cast(_request, state) do
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  # Intarnal functions
  defp message_types(message) do
    message_types_acc(Map.keys(message), [])
  end

  defp message_types_acc([], acc) do
    acc
  end

  # TODO entities, inline_query, photo
  defp message_types_acc(["forward_from" | rest], acc) do
    message_types_acc(rest, [:forwarded | acc])
  end

  defp message_types_acc(["reply_to_message" | rest], acc) do
    message_types_acc(rest, [:replied | acc])
  end

  defp message_types_acc(["edit_date" | rest], acc) do
    message_types_acc(rest, [:edited | acc])
  end

  defp message_types_acc(["audio" | rest], acc) do
    message_types_acc(rest, [:audio | acc])
  end

  defp message_types_acc(["voice" | rest], acc) do
    message_types_acc(rest, [:voice | acc])
  end

  defp message_types_acc(["document" | rest], acc) do
    message_types_acc(rest, [:document | acc])
  end

  defp message_types_acc(["text" | rest], acc) do
    message_types_acc(rest, [:text | acc])
  end

  defp message_types_acc([_ | rest], acc) do
    message_types_acc(rest, acc)
  end

  defp publish_message(message, update_id, publish_type) do
    Logger.debug("[#{update_id}] publishing message of type #{publish_type}")
    PubSub.publish_to(publish_type, message)
  end

end
