defmodule SMF do
  alias SMF.{Event, VLQ}

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

  defp parse_tracks(<<>>, acc) do
    Map.put(acc, :track_data, Enum.reverse(acc.track_data))
  end

  defp parse_tracks(
         <<"MTrk", len::integer-32, track_events::bytes-size(len), rest::binary>>,
         acc
       ) do
    parse_tracks(
      rest,
      Map.put(acc, :track_data, [parse_events(track_events, []) | acc.track_data])
    )
  end

  defp parse_events(<<>>, acc), do: Enum.reverse(acc) |> IO.inspect()

  defp parse_events(data, acc) do
    case VLQ.decode(data) do
      {:ok, delta, event} ->
        {event, rest} = Event.parse(event)
        parse_events(rest, [{delta, event} | acc])

      err ->
        err
    end
  end
end
