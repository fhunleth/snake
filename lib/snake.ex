defmodule Snake do
  @moduledoc """
  Snake!
  """

  @doc """
  Play a game
  """
  defdelegate run(), to: Snake.Game
end
