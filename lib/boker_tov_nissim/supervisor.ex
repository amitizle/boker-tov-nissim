defmodule BokerTovNissim.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      worker(BokerTovNissim.Worker, []),
      # Handlers TODO extract ot their own supervisor
      worker(BokerTovNissim.Handlers.TheCatApi, []),
      worker(BokerTovNissim.Handlers.Tch, []),
      worker(BokerTovNissim.Handlers.SimpleRegex, []),
      worker(BokerTovNissim.Handlers.Version, []),
      # End Handlers
      worker(BokerTovNissim.Messenger, []),
      supervisor(BokerTovNissim.HTTP.Supervisor, [])
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
