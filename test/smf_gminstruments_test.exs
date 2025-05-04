defmodule SMFGMInstrumentsTest do
  use ExUnit.Case
  doctest SMF.GMInstruments
  alias SMF.GMInstruments

  test "describe patch voices" do
    assert GMInstruments.describe(-1) == {:error, "Cannot describe patch (-1)"}
    assert GMInstruments.describe(0) == "Acoustic Grand Piano"
    assert GMInstruments.describe(127) == "Gunshot"
    assert GMInstruments.describe(128) == {:error, "Cannot describe patch (128)"}
    assert GMInstruments.describe("Gunshot") == {:error, "Cannot describe patch (Gunshot)"}
  end
end
