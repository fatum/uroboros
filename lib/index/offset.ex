defmodule Uroboros.Index.Offset do
  use GenServer

  defstruct [:initial_offset, :file_path, :table]

  def start_link([initial_offset, file_path]) do
    table = :ets.new(:offset_index, [:ordered_set])
    state = %__MODULE__{initial_offset: initial_offset, file_path: file_path, table: table}

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(data) do
    {:ok, data}
  end

  def handle_call(:load, _from, state) do
    {:reply, :ok, state}
  end
end
