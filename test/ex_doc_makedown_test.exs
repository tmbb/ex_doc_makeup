defmodule ExDocMakeupTest do
  use ExUnit.Case
  doctest ExDocMakeup

  test "greets the world" do
    assert ExDocMakeup.hello() == :world
  end
end
