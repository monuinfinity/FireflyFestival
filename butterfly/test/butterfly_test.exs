defmodule ButterflyTest do
  use ExUnit.Case
  doctest Butterfly

  test "greets the world" do
    assert Butterfly.hello() == :world
  end
end
