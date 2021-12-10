defmodule Uroboros.Index.Offset do
  use GenServer

  defstruct [:initial_offset, :file_path, :table]

  @spec init([...]) ::
          {:ok, %Uroboros.Index.Offset{file_path: any, initial_offset: any, table: nil}}
  def init([initial_offset, file_path]) do
    {:ok, %__MODULE__{initial_offset: initial_offset, file_path: file_path}}
  end

  def handle_call(:load, _from, state) do
    {:reply, :ok, state}
  end
end
