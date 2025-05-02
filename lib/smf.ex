defmodule SMF do
  @moduledoc """
  Main interface to Simple Midi Files
  """

  @doc """
    Read and parse MIDI data file
  """
  def parse_file(filename) do
    case File.read(Path.expand(filename)) do
      {:ok, fdata} -> parse_data(fdata)
      other -> other
    end
  end

  @formats {:single_track, :multi_track, :multi_song}

  @doc """
  Parse raw SMF data
  """
  def parse_data(
        <<"MThd", 6::integer-32, format::integer-16, tracks::integer-16, division::integer-16,
          track_data::binary>>
      ) do
    case format < tuple_size(@formats) do
      false ->
        {:error, "Unrecognized format"}

      true ->
        parse_tracks(track_data, %{
          format: elem(@formats, format),
          tracks: tracks,
          division: division,
          track_data: []
        })
    end
  end

  def parse_data(_), do: {:error, "Data does not start with a recognized header"}

  defp parse_tracks(
         <<"MTrk", len::integer-32, _track_events::bytes-size(len), _rest::binary>>,
         acc
       ) do
    acc
  end
end
