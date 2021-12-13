defmodule Uroboros.Supervisor do
  use Supervisor

  alias Uroboros.Index.Supervisor, as: IndexSupervisor
  alias Uroboros.Log.Supervisor, as: LogSupervisor

  def init(_) do
    children = [
      IndexSupervisor,
      LogSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
