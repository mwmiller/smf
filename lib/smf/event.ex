defmodule SMF.Event do
  import Bitwise
  alias SMF.{VLQ, KeySignature, Notes, GMInstruments}

  @moduledoc """
  Interpreting track events
  """

  @doc """
  Parse an event into a useful structure
  Returns {event, unused data}
  """
  # The weird variety of ways in which the pattern matches are written has
  # to do with the source document used.  I might clean up later.
  # Who am I kidding?
  def parse(
        <<1::1, 0::1, 0::1, switch::1, channel::integer-4, 0::1, note::integer-7, 0::1,
          velocity::integer-7, rest::binary>>
      ) do
    type =
      case switch do
        0 -> :noteoff
        1 -> :noteon
      end

    {%{type: type, channel: channel, note: Notes.decode(note), velocity: velocity}, rest}
  end

  def parse(
        <<1::1, 0::1, 1::1, 0::1, channel::integer-4, 0::1, note::integer-7, 0::1,
          pressure::integer-7, rest::binary>>
      ) do
    {%{type: :key_pressure, channel: channel, note: note, pressure: pressure}, rest}
  end

  def parse(
        <<1::1, 0::1, 1::1, 1::1, channel::integer-4, 0::1, controller::integer-7, 0::1,
          value::integer-7, rest::binary>>
      ) do
    # Deal with mode changes on reserved channels
    chan_msg =
      case {channel, value} do
        {122, 0} -> %{type: :channel_mode, local_mode: :off}
        {122, 127} -> %{type: :channel_mode, local_mode: :on}
        {123, 0} -> %{type: :channel_mode, all_notes_off: :off}
        {124, 0} -> %{type: :channel_mode, omni_mode: :on, all_notes: :off}
        {125, 0} -> %{type: :channel_mode, omni_mode: :off, all_notes: :off}
        {126, m} -> %{type: :channel_mode, mono_mode: :on, channel_count: m, all_notes: :off}
        {127, 0} -> %{type: :channel_mode, mono_mode: :off, all_notes: :off}
        {_, v} -> %{type: :control_change, value: v}
      end

    {Map.merge(chan_msg, %{channel: channel, controller: controller}), rest}
  end

  def parse(
        <<1::1, 1::1, 0::1, 0::1, channel::integer-4, 0::1, program::integer-7, rest::binary>>
      ) do
    {%{
       type: :program_change,
       channel: channel,
       program: program,
       description: GMInstruments.describe(program)
     }, rest}
  end

  def parse(
        <<1::1, 1::1, 0::1, 1::1, channel::integer-4, 0::1, pressure::integer-7, rest::binary>>
      ) do
    {%{type: :channel_pressure, channel: channel, pressure: pressure}, rest}
  end

  def parse(
        <<1::1, 1::1, 1::1, 0::1, channel::integer-4, 0::1, lsb::integer-7, 0::1, msb::integer-7,
          rest::binary>>
      ) do
    {%{type: :pitch_wheel_change, channel: channel, value: bsr(msb, 7) + lsb}, rest}
  end

  def parse(<<0xF0, rest::binary>>) do
    case VLQ.decode_and_split(rest) do
      # It should end with 0xF7.  I'm not sure if
      # Postel's Law applies here.
      {:ok, data, left} -> {%{type: :system_exclusive, data: data}, left}
      err -> err
    end
  end

  def parse(<<0xFF, 0x01, rest::binary>>) do
    case VLQ.decode_and_split(rest) do
      {:ok, text, left} -> {%{type: :text, text: text}, left}
      err -> err
    end
  end

  def parse(<<0xFF, 0x03, rest::binary>>) do
    case VLQ.decode_and_split(rest) do
      {:ok, tn, left} -> {%{type: :track_name, name: tn}, left}
      err -> err
    end
  end

  def parse(<<0xFF, 0x20, 0x01, cc::integer, rest::binary>>) do
    {%{type: :channel_prefix, channel: cc}, rest}
  end

  # TODO: Figure out what this is
  def parse(<<0xFF, 0x21, rest::binary>>) do
    case VLQ.decode_and_split(rest) do
      {:ok, uk, left} -> {%{type: :unknown, value: uk}, left}
      err -> err
    end
  end

  def parse(<<0xFF, 0x2F, 0x00>>), do: {%{type: :end_of_track}, <<>>}

  # TODO: this was poorly documentedin my source
  # Figure out prporer parsing and meaning of, well, everything
  def parse(
        <<0xFF, 0x54, hour::integer, min::integer, sec::integer, fr::integer-16, ff::integer,
          rest::binary>>
      ) do
    {%{type: :smpte_offset, hour: hour, minute: min, second: sec, fr: fr, fractional_frames: ff},
     rest}
  end

  def parse(<<0xFF, 0x51, 0x03, tempo::integer-24, rest::binary>>) do
    {%{type: :set_tempo, μs_per_quarter: tempo}, rest}
  end

  def parse(
        <<0xFF, 0x58, 0x04, num::integer, dpow::integer, cpc::integer, tpq::integer,
          rest::binary>>
      ) do
    {%{
       type: :time_signature,
       numerator: num,
       denominator: bsl(1, dpow),
       clocks_per_click: cpc,
       thirty_per_quarter: tpq
     }, rest}
  end

  def parse(<<0xFF, 0x59, 0x02, sf::signed-integer, mi::integer, rest::binary>>) do
    {%{type: :key_signature, signature: KeySignature.decode(sf, mi)}, rest}
  end

  def parse(<<0xFF, 0x7F, rest::binary>>) do
    case VLQ.decode(rest) do
      {:ok, len, more} ->
        case more do
          <<0x00, man_id::integer-16, data::bytes-size(len - 3), left::binary>> ->
            {%{type: :sequencer_specific, manufacturer_id: man_id, data: data}, left}

          <<man_id::integer, data::bytes-size(len - 1), left::binary>> ->
            {%{type: :sequencer_specific, manufacturer_id: man_id, data: data}, left}
        end

      err ->
        err
    end
  end
end
