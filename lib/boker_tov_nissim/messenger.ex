defmodule BokerTovNissim.Messenger do
  use GenServer
  require Logger

  @server :messenger
  @send_response_retries 3

  # For all opts see the official API docs:
  # https://core.telegram.org/bots/api#available-methods

  defmacro with_probability(probability, do: expression) do
    quote do
      case :rand.uniform() < unquote(probability) do
        true -> unquote(expression)
        _ -> Logger.debug("skipped sending message do to probability")
      end
    end
  end

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  def send_text(chat_id, text, resp_probability, opts \\ []) do
    with_probability(resp_probability, do: GenServer.cast(@server, {:send_text, chat_id, text, opts, @send_response_retries}))
  end

  def send_photo(chat_id, photo_file_path, resp_probability, opts \\ []) do
    with_probability(resp_probability, do: GenServer.cast(@server, {:send_photo, chat_id, photo_file_path, opts, @send_response_retries}))
  end

  # Callbacks

  def init(_args) do
    {:ok, %{}}
  end

  def handle_cast({send_type, chat_id, _, _opts, 0}, state) do
    Logger.error("exhausted all retries sendint #{send_type} to #{chat_id}")
    {:noreply, state}
  end

  def handle_cast({:send_text, chat_id, text, opts, retries}, state) do
    case Nadia.send_message(chat_id, text, opts) do
      {:ok, _} ->
        Logger.debug("sent message #{text} to #{chat_id}")
      {:error, %Nadia.Model.Error{reason: reason}} ->
        Logger.error("error sending #{text} to #{chat_id}, reason: #{reason}, retries left: #{retries - 1}")
        GenServer.cast(@server, {:send_text, chat_id, text, opts, retries - 1})
    end
    {:noreply, state}
  end

  def handle_cast({:send_photo, chat_id, photo_file_path, opts, retries}, state) do
    case Nadia.send_photo(chat_id, photo_file_path, opts) do
      {:ok, _} ->
        Logger.debug("sent a photo message to #{chat_id}")
      {:error, %Nadia.Model.Error{reason: reason}} ->
        Logger.error("error sending photo to #{chat_id}, reason: #{reason}, retries left: #{retries - 1}")
        GenServer.cast(@server, {:send_photo, chat_id, photo_file_path, opts, retries - 1})
    end
    {:noreply, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

end
