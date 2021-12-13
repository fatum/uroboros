defmodule Uroboros.Index.Supervisor do
  use Supervisor

  alias Uroboros.Index.{Offset, Timestamp}

  @types [Offset, Timestamp]

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def load_index(db_name) when is_binary(db_name) do
    started_indexes = running_indexes_types(db_name)

    mapping =
      %{}
      |> Map.put(Offset, "offset")
      |> Map.put(Timestamp, "ts")

    for type <- @types do
      if not Enum.member?(started_indexes, type) do
        ext = mapping[type]
        file_path = Path.join([Uroboros.data_dir(), db_name, "index.#{ext}"])

        Supervisor.start_child(__MODULE__, %{
          id: {db_name, type},
          start:
            {type, :start_link,
             [
               [
                 initial_position: 0,
                 file_path: file_path
               ]
             ]}
        })
      end
    end

    indexes_for(db_name)
  end

  def offload_index(db_name) when is_binary(db_name) do
  end

  def indexes_for(db_name) do
    for child <- Supervisor.which_children(__MODULE__),
        child |> elem(0) |> elem(0) == db_name,
        do: child
  end

  defp running_indexes_types(db_name) do
    Enum.filter(Supervisor.which_children(__MODULE__), fn child ->
      {child_db_name, type} = elem(child, 0)

      if child_db_name == db_name do
        [type]
      else
        []
      end
    end)
  end
end
