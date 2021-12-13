defmodule Uroboros.OffsetServerTest do
  use ExUnit.Case

  alias Uroboros.Index.Supervisor, as: IndexSupervisor

  setup do
    {:ok, pid} = IndexSupervisor.start_link()

    [pid: pid]
  end

  test "starts index processes for database" do
    # run loading index twice and check that
    # we created only one pair of indexes for each db
    IndexSupervisor.load_index("partition-1")

    assert [
             {{"partition-1", _}, _, _, _},
             {{"partition-1", _}, _, _, _}
           ] = IndexSupervisor.load_index("partition-1")
  end
end
