# Uroboros

This library allows you create high performance append-only storage with 1 writer and many readers per database (or partition if we speak in Kafka terminology). There is only one writer so all data is ordered by offset (Int64 value).

It's based mostly on ideas from Kafka Internals:

- https://jaceklaskowski.gitbooks.io/apache-kafka/content/kafka-log-AbstractIndex.html
- https://jaceklaskowski.gitbooks.io/apache-kafka/content/kafka-log-OffsetIndex.html
- https://www.waitingforcode.com/apache-kafka/offset-based-lookup-apache-kafka/read

## How it works

This library provides simple API for reading/writing commit log with auto compaction by date/size threshold.

Example

```elixir
# initializes db related data like indexes and file descriptors, starts repairing if needed
Uroboros.open("partition-1")

# stops consumer related processes
Uroboros.stop_consumer("partition-1", consumer_id)

# close database indexes, consumers and writer processes
Uroboros.close("partition-1")

# starts reading data for specifed offsets
# this call starts supervised process for each consumer_id 
# that opens database in raw mode and reads data in zero-copy way
stream = Uroboros.read_offset("partition-1", consumer_id, [start: 10000343, end: 10000353])

# starts reading data from specific offset
# this call starts supervised process for each consumer_id 
# that opens database in raw mode and reads data in zero-copy way
stream = Uroboros.read_offset("partition-1", consumer_id, [start: 10000343, end: 10000353])

# adds new data and return last applied offset
# this call also starts supervised process that opens database and allows reading specified offsets
offset = Uroboros.write("partition-1", binaries)
```

```elixir
defmodule MyApp do
  use Application

  def start(_type, _args) do
    children = [
      {Uroboros.Supervisor, [data_dir: "path_to_db_storage"]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
``` 

### Supervisors and Processes

- Uroboros.Supervisor 

It assembles all other Supervisors and handles settings and ordering.

- Uroboros.ReaderSupervisor

This is an internal supervisor manages streaming big batches for specified offsets w/o any decoding (zero copy IO).

- Uroboros.IndexesManagerSupervisor

This is an internal supervisor handles indexes for efficient data scanning by offsets or timestamp intervals. For each database that opened it creates `Uroboros.IndexSupervisor` that manages 2 processes – for offset index and timestamp index respectively.

- Uroboros.Index.Offset

This process reads current index data from the disk, loads it into ets table and provide this private API for other process

```elixir
# returns position on the database file for the requested offset
Uroboros.Index.Offset.get_position(pid, offset)

```

- Uroboros.Index.Timestamp

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `uroboros` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uroboros, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/uroboros](https://hexdocs.pm/uroboros).
