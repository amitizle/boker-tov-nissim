
defmodule BokerTovNissim.HTTP do
  use GenServer
  require Logger

  @server :http

  # API

  def get(url, headers, http_opts) do
    retries = 3
    ref = make_ref()
    GenServer.cast(@server, {:get, url, headers, http_opts, ref, self(), retries})
    ref
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

  def handle_cast({:get, url, _headers, _http_opts, _ref, _reply_to, 0}, state) do
    Logger.error("exhausted all retries for #{url}")
    # TODO respond with error
    {:noreply, state}
  end
  def handle_cast({:get, url, headers, http_opts, ref, reply_to, retries}, state) do
    case :poolboy.transaction(:http_worker, http_fn(:get, url, headers, http_opts)) do
      {:ok, response} ->
        send_response(reply_to, response, ref)
      {:error, reason} ->
        Logger.warn("error while requesting #{url}; #{reason}, retrying")
        GenServer.cast(@server, {:get, url, headers, http_opts, ref, reply_to, retries - 1})
    end
    {:noreply, state}
  end


  # Internal

  defp send_response(pid, response, ref) do
    send(pid, {:http_response, ref, response})
  end

  defp http_fn(method, url, headers, http_opts) do
    fn(pid) ->
      GenServer.call(pid, {method, url, headers, http_opts})
    end
  end

end
