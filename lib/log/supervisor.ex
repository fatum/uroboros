defmodule Uroboros.Log.Supervisor do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
