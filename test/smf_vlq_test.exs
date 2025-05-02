defmodule SMFVLQTest do
  use ExUnit.Case
  doctest SMF.VLQ
  alias SMF.VLQ

  # These are written with hex values even where it seems odd
  # in order to match the reference I am using.
  test "decode variable length quantities" do
    assert VLQ.decode(<<0x00>>) == {:ok, 0x00, ""}
    assert VLQ.decode(<<0x40>>) == {:ok, 0x40, ""}
    assert VLQ.decode(<<0x7F>>) == {:ok, 0x7F, ""}
    assert VLQ.decode(<<0x81, 0x00, "plus">>) == {:ok, 0x80, "plus"}
    assert VLQ.decode(<<0xC0, 0x00>>) == {:ok, 0x2000, ""}
    assert VLQ.decode(<<0xFF, 0x7F>>) == {:ok, 0x3FFF, ""}
    assert VLQ.decode(<<0x81, 0x80, 0x00, "some">>) == {:ok, 0x4000, "some"}
    assert VLQ.decode(<<0x81, 0x80, 0x00>>) == {:ok, 0x4000, ""}
    assert VLQ.decode(<<0xC0, 0x80, 0x00>>) == {:ok, 0x100000, ""}
    assert VLQ.decode(<<0xFF, 0xFF, 0x7F, "data">>) == {:ok, 0x1FFFFF, "data"}
    assert VLQ.decode(<<0x81, 0x80, 0x80, 0x00>>) == {:ok, 0x200000, ""}
    assert VLQ.decode(<<0xC0, 0x80, 0x80, 0x00>>) == {:ok, 0x8000000, ""}

    assert VLQ.decode(<<0xFF, 0xFF, 0xFF, 0x7F, "and so much more!">>) ==
             {:ok, 0xFFFFFFF, "and so much more!"}

    assert VLQ.decode(<<0xFF, 0xFF, 0xFF, 0x8F, "and so much more!">>) ==
             {:error, "Error decoding variable length quantity"}
  end

  test "encode variable length quantities" do
    assert VLQ.encode(0x00) == <<0x00>>
    assert VLQ.encode(0x40) == <<0x40>>
    assert VLQ.encode(0x7F) == <<0x7F>>
    assert VLQ.encode(0x80) == <<0x81, 0x00>>
    assert VLQ.encode(0x2000) == <<0xC0, 0x00>>
    assert VLQ.encode(0x3FFF) == <<0xFF, 0x7F>>
    assert VLQ.encode(0x4000) == <<0x81, 0x80, 0x00>>
    assert VLQ.encode(0x100000) == <<0xC0, 0x80, 0x00>>
    assert VLQ.encode(0x1FFFFF) == <<0xFF, 0xFF, 0x7F>>
    assert VLQ.encode(0x200000) == <<0x81, 0x80, 0x80, 0x00>>
    assert VLQ.encode(0x8000000) == <<0xC0, 0x80, 0x80, 0x00>>
    assert VLQ.encode(0xFFFFFFF) == <<0xFF, 0xFF, 0xFF, 0x7F>>

    assert VLQ.encode(0x10000000) ==
             {:error, "268435456 is too large for variable length quantity"}

    assert VLQ.encode("one") == {:error, "Can only encode postive integers"}
    assert VLQ.encode(-1) == {:error, "Can only encode postive integers"}
  end
end
