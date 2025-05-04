defmodule SMF.GMInstruments do
  @moduledoc """
  Mapping of General MIDI instruments
  """
  @instruments_tuple Path.join([:code.priv_dir(:smf), "gminstruments.list"])
                     |> File.read!()
                     |> String.split("\n")
                     |> List.to_tuple()

  @doc """
  Describe a general MIDI instrument from its program.
  """

  def describe(patch) when patch >= 0 and patch < tuple_size(@instruments_tuple) - 1 do
    elem(@instruments_tuple, patch)
  end

  def describe(patch),
    do: {:error, "Cannot describe patch (#{patch})"}
end
