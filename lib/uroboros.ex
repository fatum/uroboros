defmodule Uroboros do
  @moduledoc """
  This module provides public API for database operations
  """

  alias Uroboros.Index.Supervisor, as: IndexSupervisor

  def data_dir, do: "/tmp/uroboros"

  def open(db_name) when is_atom(db_name), do: open(Atom.to_string(db_name))

  def open(db_name) when is_binary(db_name) do
    # Load index into sorted ets table
    IndexSupervisor.load_index(db_name)

    # Pepair index if needed
    # IndexSupervisor.repair_index(db_name)
  end

  def close(db_name) when is_atom(db_name), do: close(Atom.to_string(db_name))

  def close(db_name) when is_binary(db_name) do
    IndexSupervisor.offload_index(db_name)
  end
end
