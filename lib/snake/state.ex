defmodule Snake.State do
  defstruct width: 80,
            height: 24,
            game_win: nil,
            snake: [],
            direction: :down,
            food: nil,
            game_over: false,
            timer: nil,
            score: 0
end
