defmodule SMFNotesTest do
  use ExUnit.Case
  doctest SMF.Notes
  alias SMF.Notes

  test "decode to mapped values" do
    assert Notes.decode(-1) == {:error, "Cannot decode note (-1)"}
    assert Notes.decode(0) == %{flats: "C-1", sharps: "C-1"}
    assert Notes.decode(42) == %{flats: "G♭2", sharps: "F♯2"}
    assert Notes.decode(94) == %{flats: "B♭6", sharps: "A♯6"}
    assert Notes.decode(127) == %{flats: "G9", sharps: "G9"}
    assert Notes.decode(128) == {:error, "Cannot decode note (128)"}
    assert Notes.decode("C") == {:error, "Cannot decode note (C)"}
    assert Notes.decode(60.0) == {:error, "Cannot decode note (60.0)"}
  end
end
