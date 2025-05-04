defmodule SMF.Notes do
  @moduledoc """
  Deal with MIDI encoded notes
  """

  # I'm lazy, so let the compiler do the work.
  @notes_map [
               ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "C♭"],
               ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
             ]
             |> Enum.zip()
             |> List.to_tuple()

  @percussion_tuple Path.join([:code.priv_dir(:smf), "gmpercussion.list"])
                    |> File.read!()
                    |> String.split("\n")
                    |> List.to_tuple()

  @doc """
  Decode a note number into a map of human-readable strings

  Perhaps to come is a function to map inside a scale given a
  derived keysignature string

  Channel 9 is percussion special form
  """
  def decode(note, channel \\ 0)

  def decode(note, 9) when note >= 35 and note < 34 + tuple_size(@percussion_tuple) do
    %{percussion: elem(@percussion_tuple, note - 35)}
  end

  def decode(note, channel) when note in 0..127 and is_integer(channel) and channel != 9 do
    # Broken out here for the sake of the reader
    octave = to_string(div(note, 12) - 1)
    {flat, sharp} = elem(@notes_map, rem(note, 12))
    %{flats: flat <> octave, sharps: sharp <> octave}
  end

  def decode(note, channel), do: {:error, "Cannot decode note (#{note}) for channel (#{channel})"}
end
