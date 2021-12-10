defmodule Uroboros.LogEntryTest do
  use ExUnit.Case, async: true
  doctest Uroboros.Log.Entry

  alias Uroboros.Log.{Entry, Record}

  def create_entry(ts \\ 123_424) do
    %Entry{
      start_offset_id: 1,
      end_offset_id: 2,
      ts: ts,
      records: [
        %Record{offset_id: 1, ts: 123_424, payload: <<1::integer>>},
        %Record{offset_id: 2, ts: 123_425, payload: <<2::integer>>}
      ]
    }
  end

  test "encodes LogEntry data structure to binary" do
    entry = create_entry()

    assert is_binary(Entry.to_binary(entry))
  end

  test "fails on invalid bytes streams" do
    entry = :crypto.strong_rand_bytes(10)

    assert Entry.from_binary(entry) == {:error, :invalid}
  end

  test "decodes encoded Entry" do
    entry = create_entry()

    assert {:ok, entry, <<>>} == Entry.from_binary(Entry.to_binary(entry))
  end

  test "matching part of binary" do
    entry1 = create_entry(111_111)
    entry2 = create_entry(222_222)

    payload = :crypto.strong_rand_bytes(10)

    data = Enum.join([Entry.to_binary(entry1), Entry.to_binary(entry2), payload])

    assert {:ok, _entry1, rest} = Entry.from_binary(data)
    assert {:ok, _entry2, _payload} = Entry.from_binary(rest)
  end
end
