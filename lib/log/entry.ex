defmodule Uroboros.Log.Entry do
  alias Uroboros.Log.Record

  defstruct [:start_offset_id, :end_offset_id, :ts, :records]

  @spec from_binary(binary) :: {:ok, %Uroboros.Log.Entry{}, binary} | {:error, :invalid}
  def from_binary(<<
        start_offset_id::64-unsigned-integer,
        end_offset_id::64-unsigned-integer,
        records_count::unsigned-integer,
        ts::32-unsigned-integer,
        records_size::unsigned-integer,
        records::size(records_size)-bytes,
        rest::bytes
      >>) do
    {:ok,
     %__MODULE__{
       start_offset_id: start_offset_id,
       end_offset_id: end_offset_id,
       ts: ts,
       records: records_from_binary(records, records_count)
     }, rest}
  end

  def from_binary(data) when is_binary(data), do: {:error, :invalid}

  @spec to_binary(%Uroboros.Log.Entry{
          :start_offset_id => integer,
          :end_offset_id => integer,
          :ts => integer,
          :records => list()
        }) :: binary()
  def to_binary(entry = %__MODULE__{}) do
    payload = entry.records |> Enum.map(&record_to_binary/1) |> Enum.join()

    <<
      entry.start_offset_id::64-unsigned-integer,
      entry.end_offset_id::64-unsigned-integer,
      length(entry.records)::unsigned-integer,
      entry.ts::32-unsigned-integer,
      byte_size(payload)::unsigned-integer,
      payload::bytes
    >>
  end

  @spec record_to_binary(%Uroboros.Log.Record{
          :offset_id => integer,
          :payload => binary,
          :ts => integer
        }) :: nonempty_binary
  def record_to_binary(record = %Record{}) do
    payload = <<
      record.offset_id::64-unsigned-integer,
      record.ts::32-unsigned-integer,
      record.payload::bytes
    >>

    <<byte_size(payload)::unsigned-integer, payload::bytes>>
  end

  defp records_from_binary(<<data::bytes>>, records_count) do
    records_from_binary(data, [], records_count)
  end

  defp records_from_binary(<<_any::bytes>>, records, 0), do: Enum.reverse(records)

  defp records_from_binary(
         <<record_size::unsigned-integer, record::size(record_size)-bytes, rest::bytes>>,
         records,
         records_count
       ) do
    records_from_binary(rest, [parse_record(record) | records], records_count - 1)
  end

  defp records_from_binary(
         <<record_size::unsigned-integer, record::size(record_size)-bytes>>,
         records,
         records_count
       ) do
    records_from_binary(<<>>, [parse_record(record) | records], records_count - 1)
  end

  defp parse_record(<<offset_id::64-unsigned-integer, ts::32-unsigned-integer, payload::bytes>>) do
    %Record{offset_id: offset_id, ts: ts, payload: payload}
  end
end
