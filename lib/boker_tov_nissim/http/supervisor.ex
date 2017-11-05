
defmodule BokerTovNissim.HTTP.Supervisor do

  use Supervisor

  @supervisor :http_supervisor
  @pool_name :http_worker

  def start_link do
    children = [
      :poolboy.child_spec(:worker, poolboy_config()),
      worker(BokerTovNissim.HTTP, [])
    ]
    opts = [strategy: :one_for_one, name: @supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def start(_type, _args) do
    children = [
      :poolboy.child_spec(@pool_name, poolboy_config()),
      worker(BokerTovNissim.HTTP, [])
    ]
    opts = [strategy: :one_for_one, name: @supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config do
    [
      {:name, {:local, @pool_name}},
      {:worker_module, BokerTovNissim.HTTP.Worker},
      {:size, 5},
      {:max_overflow, 3}
    ]
  end

end
