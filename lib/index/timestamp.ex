defmodule Uroboros.Index.Timestamp do
  use GenServer

  defstruct [:initial_ts, :file_path, :table]

  def start_link([initial_ts, file_path]) do
    table = :ets.new(:ts_index, [:ordered_set])
    state = %__MODULE__{initial_ts: initial_ts, file_path: file_path, table: table}

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(data) do
    {:ok, data}
  end
end
