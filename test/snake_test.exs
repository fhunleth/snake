defmodule SnakeTest do
  use ExUnit.Case
  doctest Snake

  test "greets the world" do
    assert Snake.hello() == :world
  end
end
