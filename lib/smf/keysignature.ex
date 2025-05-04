defmodule SMF.KeySignature do
  # 0 is major, 1 is minor
  @scale {"Maj", "Min"}

  # Scales arranged as above
  # Flat count + 7 is the index into the column
  @key_map {{"C♭", "G♭", "D♭", "A♭", "E♭", "B♭", "F", "C", "G", "D", "A", "E", "B", "F♯", "C♯"},
            {"A♭", "E♭", "B♭", "F", "C", "G", "D", "A", "E", "B", "F♯", "C♯", "G♯", "D♯", "A♯"}}

  @doc """
  Converts the flat count and scale selection to a human-readable string
  """
  def decode(flat_count, scale) when flat_count in -7..7 and scale in [0, 1] do
    elem(elem(@key_map, scale), flat_count + 7) <> elem(@scale, scale)
  end

  def decode(_, _), do: "improper"
end
