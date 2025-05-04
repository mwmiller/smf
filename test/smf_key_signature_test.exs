defmodule SMFKeySignatureTest do
  use ExUnit.Case
  doctest SMF.KeySignature
  alias SMF.KeySignature

  test "decode major keys" do
    assert KeySignature.decode(0, 0) == "CMaj"
    assert KeySignature.decode(-7, 0) == "C♭Maj"
    assert KeySignature.decode(7, 0) == "C♯Maj"
    assert KeySignature.decode(3, 0) == "AMaj"
    assert KeySignature.decode(-3, 0) == "E♭Maj"
  end

  test "decode minor keys" do
    assert KeySignature.decode(0, 1) == "AMin"
    assert KeySignature.decode(-7, 1) == "A♭Min"
    assert KeySignature.decode(7, 1) == "A♯Min"
    assert KeySignature.decode(3, 1) == "F♯Min"
    assert KeySignature.decode(-3, 1) == "CMin"
  end

  test "improper parameters" do
    assert KeySignature.decode(0, -1) == "improper"
    assert KeySignature.decode(0, 2) == "improper"
    assert KeySignature.decode(-8, 0) == "improper"
    assert KeySignature.decode(8, 1) == "improper"
  end
end
