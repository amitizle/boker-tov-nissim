defmodule BokerTovNissim.WebServer.BotHandler do
  require Logger

  # Callbacks

  def init(request, state) do
    Logger.info(inspect(request))
    {:cowboy_rest, request, state}
  end

  def allowed_methods(request, state) do
    {["GET", "POST"], request, state}
  end

  def content_types_accepted(request, state) do
    {[
      {{"application", "json", []}, :process_event}],
      request, state}
  end

  # def content_types_provided(request, state) do
  #   {[
  #     {{"application", "json", []}, :json_response}
  #   ], request, state}
  # end

  def allow_missing_post(request, state) do
    {false, request, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  # Internal functions

  def process_event(request, state) do
    {:ok, body, request_2} = :cowboy_req.read_body(request)
    p = Poison.decode!(body)
    BokerTovNissim.Worker.process_message(p)
    # Nadia.send_message(38547945, "hey")
    {true, request_2, state}
  end
end
