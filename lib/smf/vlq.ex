defmodule SMF.VLQ do
  @moduledoc """
  Functions to deal with variable length quanities
  """

  import Bitwise

  @doc """
  Extract a variable length quantity from up to 4 bytes.
  On success: {:ok, value, unused bytes}
  On failue: {:error, reason}
  """

  def decode(<<0::1, size::integer-7, rest::binary>>), do: {:ok, size, rest}

  def decode(<<1::1, lm::integer-7, 0::1, low::integer-7, rest::binary>>),
    do: {:ok, bsl(lm, 7) + low, rest}

  def decode(<<1::1, hm::integer-7, 1::1, lm::integer-7, 0::1, low::integer-7, rest::binary>>),
    do: {:ok, bsl(hm, 14) + bsl(lm, 7) + low, rest}

  def decode(
        <<1::1, high::integer-7, 1::1, hm::integer-7, 1::1, lm::integer-7, 0::1, low::integer-7,
          rest::binary>>
      ),
      do: {:ok, bsl(high, 21) + bsl(hm, 14) + bsl(lm, 7) + low, rest}

  def decode(_), do: {:error, "Error decoding variable length quantity"}

  @doc """
  Encode a positive integer into up to 4 bytes.
  On success: <<bytes>>
  On failure: {:error,reason}
  """
  def encode(n) when not is_integer(n) or n < 0,
    do: {:error, "Can only encode postive integers"}

  def encode(n) when n < bsl(1, 7), do: <<0::1, n::7>>
  def encode(n) when n < bsl(1, 14), do: <<1::1, bsr(n, 7)::7, 0::1, n::7>>

  def encode(n) when n < bsl(1, 21),
    do: <<1::1, bsr(n, 14)::7, 1::1, bsr(n, 7)::7, 0::1, n::7>>

  def encode(n) when n < bsl(1, 28),
    do: <<1::1, bsr(n, 21)::7, 1::1, bsr(n, 14)::7, 1::1, bsr(n, 7)::7, 0::1, n::7>>

  def encode(n), do: {:error, "#{n} is too large for variable length quantity"}
end
