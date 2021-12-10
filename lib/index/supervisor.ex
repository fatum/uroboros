defmodule Uroboros.Index.Supervisor do
  use Supervisor

  alias Uroboros.Index.{Offset, Timestamp}

  @types [Offset, Timestamp]

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def load_index(db_name) when is_binary(db_name) do
    started_indexes = running_indexes_for(db_name)

    for type <- @types do
      if not Enum.member?(started_indexes, type) do
        Supervisor.start_child(__MODULE__, %{
          id: {db_name, type},
          start: {type, :start_link, []}
        })
      end
    end
  end

  def offload_index(db_name) when is_binary(db_name) do
  end

  defp running_indexes_for(db_name) do
    Enum.filter(Supervisor.which_children(__MODULE__), fn child ->
      {child_db_name, type} = Map.get(child, :id)

      if child_db_name == db_name do
        [type]
      else
        []
      end
    end)
  end
end
