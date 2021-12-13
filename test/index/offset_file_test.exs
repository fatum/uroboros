defmodule Uroboros.Index.FileTest do
  use ExUnit.Case

  alias Uroboros.Index.File, as: OffsetFile

  test "writes and reads multiple records" do
    file = OffsetFile.new("/tmp/offset_file_test.index")

    assert :ok == OffsetFile.write(file, {1, 1})
    assert :ok == OffsetFile.write(file, {2, 2})
    assert :ok == OffsetFile.write(file, {3, 5})
    assert :ok == OffsetFile.write(file, {4, 15})
    assert :ok == OffsetFile.write(file, {10, 25})
    assert :ok == OffsetFile.write(file, {4_000, 1_530})

    items = Enum.map(file.stream, fn record -> record end)

    OffsetFile.close(file)
    File.rm("/tmp/offset_file_test.index")

    assert [{1, 1}, {2, 2}, {3, 5}, {4, 15}, {10, 25}, {4000, 1530}] == items
  end

  test "works with reopened file" do
    file = OffsetFile.new("/tmp/offset_file_test.index")

    assert :ok == OffsetFile.write(file, {1, 1})
    assert :ok == OffsetFile.write(file, {2, 2})
    assert :ok == OffsetFile.write(file, {3, 5})
    OffsetFile.close(file)

    file = OffsetFile.new("/tmp/offset_file_test.index")
    assert :ok == OffsetFile.write(file, {4, 15})
    assert :ok == OffsetFile.write(file, {10, 25})
    assert :ok == OffsetFile.write(file, {4_000, 1_530})

    items = Enum.map(file.stream, fn record -> record end)

    File.rm("/tmp/offset_file_test.index")

    assert [{1, 1}, {2, 2}, {3, 5}, {4, 15}, {10, 25}, {4000, 1530}] == items
  end
end
