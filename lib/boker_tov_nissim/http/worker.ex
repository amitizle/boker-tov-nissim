defmodule BokerTovNissim.HTTP.Worker do
  use GenServer
  require Logger

  # API

  # Callbacks

  def init(_args) do
    {:ok, %{}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def handle_call({:get, url, headers, http_opts}, _from, state) do
    response = HTTPoison.get(url, merged_headers(headers), merged_http_opts(http_opts))
    reply = process_response(response, url)
    {:reply, reply, state}
  end

  def process_response({:ok, %HTTPoison.Response{} = response}, _request_url) do
    {:ok, response}
  end

  def process_response({:error, %HTTPoison.Error{reason: reason}}, request_url) do
    Logger.warn("error on response for request #{request_url}; #{reason}")
    {:error, reason}
  end

  # Internal

  defp default_http_opts do
    [
      follow_redirect: true
    ]
  end

  defp merged_http_opts(http_opts) do
    Keyword.merge(default_http_opts(), http_opts)
  end

  defp default_headers do
    [
      "Accept": "Application/json"
    ]
  end

  defp merged_headers(headers) do
    Keyword.merge(default_headers(), headers)
  end

end
