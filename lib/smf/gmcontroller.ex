defmodule SMF.GMController do
  @moduledoc """
  Functions dealing the General MIDI controller data
  """

  @meanings_tuple Path.join([:code.priv_dir(:smf), "gmcontroller.list"])
                  |> File.read!()
                  |> String.split(["\t", "\n"])
                  |> Enum.chunk_every(3)
                  |> Enum.map(&List.to_tuple/1)
                  |> List.to_tuple()

  @all_notes_off %{all_notes: :off}

  defp val_for(<<0::1, val::integer-big-7>>, "0-127", "MSB") do
    val
  end

  defp val_for(<<0::1, val::integer-little-7>>, "0-127", "LSB") do
    val
  end

  defp val_for(v, r, h), do: {:error, v, r, h}

  def describe_change(controller_id, val_byte) when controller_id in 0..119 do
    {desc, range, how} = elem(@meanings_tuple, controller_id)
    %{description: desc, value: val_for(val_byte, range, how)}
  end

  def describe_change(120, <<>>) do
    %{description: "All Sound Off", sound: :off}
  end

  def describe_change(121, <<>>) do
    %{description: "Reset All Controllers", sound: :off}
  end

  def describe_change(122, <<0>>) do
    %{description: "Local Control Off", local_control: :off}
  end

  def describe_change(122, <<127>>) do
    %{description: "Local Control On", local_control: :on}
  end

  def describe_change(123, <<0>>) do
    Map.merge(%{description: "All notes off"}, @all_notes_off)
  end

  def describe_change(124, <<0>>) do
    Map.merge(%{description: "Omni mode off", omni: :off}, @all_notes_off)
  end

  def describe_change(125, <<0>>) do
    Map.merge(%{description: "Omni mode on", omni: :on}, @all_notes_off)
  end

  def describe_change(126, <<val::integer>>) do
    Map.merge(%{description: "Poly mode off", poly: :off, channels: val}, @all_notes_off)
  end

  def describe_change(127, <<0>>) do
    Map.merge(%{description: "Poly mode on", poly: :on}, @all_notes_off)
  end

  def describe_change(_, _), do: {:error, "Cannot describe provided values"}
end
