defmodule Uroboros.Index.File do
  defstruct [:path, :fd, :stream]

  def new(path) do
    {:ok, fd} = :file.open(path, [:read, :write, :raw, :binary, :append])

    initial_fn = fn -> 0 end
    end_fn = fn _ -> 0 end

    next_fn = fn position ->
      case :file.pread(fd, position, 4) do
        {:ok, <<item_size::integer-size(32)>>} ->
          case :file.pread(fd, position + 4, item_size) do
            {:ok, data} ->
              {[:erlang.binary_to_term(data)], position + 4 + item_size}

            result ->
              {:halt, result}
          end

        :eof ->
          {:halt, position}

        {:error, _reason} ->
          {:halt, position}
      end
    end

    %__MODULE__{
      path: path,
      fd: fd,
      stream:
        Stream.resource(
          initial_fn,
          next_fn,
          end_fn
        )
    }
  end

  def read(%__MODULE__{stream: stream}) do
    Stream.run(stream)
  end

  def write(%__MODULE__{fd: fd}, {_offset, _position} = item) do
    data = :erlang.term_to_binary(item)

    :file.write(fd, <<byte_size(data)::integer-size(32), data::binary>>)
  end

  def close(%__MODULE__{fd: fd}) do
    :file.close(fd)
  end
end
