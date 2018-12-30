defmodule InSimExTest do
  use ExUnit.Case
  doctest InSimEx

  test "greets the world" do
    assert InSimEx.hello() == :world
  end
end
