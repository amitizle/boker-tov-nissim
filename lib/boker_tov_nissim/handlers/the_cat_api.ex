defmodule BokerTovNissim.Handlers.TheCatApi do
  use GenServer
  require BokerTovNissim.PubSub
  alias BokerTovNissim.PubSub
  require Logger

  @server :the_cat_api
  @response_probability 1.0

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  # Callbacks

  def init(_args) do
    PubSub.subscribe_to(:text)
    regex = ~r/\b(חתולה)\b/miu
    {:ok, %{
      regex: regex,
      in_flight_requests: %{},
      cached_images: []
    }}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_message, state) do
    {:noreply, state}
  end

  def handle_info({:message, message}, %{regex: regex, in_flight_requests: in_flight_requests} = state) do
    case Regex.match?(regex, message["text"]) do
      true ->
        http_ref = BokerTovNissim.HTTP.get("http://thecatapi.com/api/images/get", [], [])
        new_in_flight_requests = Map.put(in_flight_requests, http_ref, message)
        new_state = Map.put(state, :in_flight_requests, new_in_flight_requests)
        {:noreply, new_state}
      _ ->
        {:noreply, state}
    end
  end

  def handle_info({:http_response, ref, %HTTPoison.Response{status_code: 200, body: body}}, state) do
    %{in_flight_requests: in_flight_requests} = state
    message = Map.fetch!(in_flight_requests, ref)
    new_in_flight_requests = Map.delete(in_flight_requests, ref)
    new_state = Map.put(state, :in_flight_requests, new_in_flight_requests)
    {:ok, picture_file} = BokerTovNissim.Utils.write_temp_file(body)
    chat_id = message["chat"]["id"] # TODO
    BokerTovNissim.Messenger.send_photo(chat_id, picture_file, @response_probability, [caption: random_caption()])
    {:noreply, new_state}
  end

  # Internal

  defp random_caption do
    Enum.random([
      "קח חתולה",
      "הנה חתולה זה",
      "טחח",
      "מיאו",
      "מה נז׳מיאו",
      "הופה",
      "פררררר"
    ])
  end

end
