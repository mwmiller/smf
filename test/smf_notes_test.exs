defmodule SMFNotesTest do
  use ExUnit.Case
  doctest SMF.Notes
  alias SMF.Notes

  test "decode standard to mapped values" do
    assert Notes.decode(-1) == {:error, "Cannot decode note (-1) for channel (0)"}
    assert Notes.decode(0) == %{flats: "C-1", sharps: "C-1"}
    assert Notes.decode(42) == %{flats: "G♭2", sharps: "F♯2"}
    assert Notes.decode(94) == %{flats: "B♭6", sharps: "A♯6"}
    assert Notes.decode(127) == %{flats: "G9", sharps: "G9"}
    assert Notes.decode(128) == {:error, "Cannot decode note (128) for channel (0)"}
    assert Notes.decode("C") == {:error, "Cannot decode note (C) for channel (0)"}
    assert Notes.decode(60.0) == {:error, "Cannot decode note (60.0) for channel (0)"}
    assert Notes.decode(42, :one) == {:error, "Cannot decode note (42) for channel (one)"}
  end

  test "decode percussion to mapped value" do
    assert Notes.decode(-1, 9) == {:error, "Cannot decode note (-1) for channel (9)"}
    assert Notes.decode(34, 9) == {:error, "Cannot decode note (34) for channel (9)"}
    assert Notes.decode(35, 9) == %{percussion: "Acoustic Bass Drum"}
    assert Notes.decode(56, 9) == %{percussion: "Cowbell"}
    assert Notes.decode(81, 9) == %{percussion: "Open Triangle"}
    assert Notes.decode(82, 9) == {:error, "Cannot decode note (82) for channel (9)"}
  end
end
