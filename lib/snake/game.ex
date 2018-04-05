defmodule Snake.Game do
  alias Snake.UI
  require Logger

  @tick 200

  defp init(state) do
    state
    |> UI.init()
    |> place_snake()
    |> place_food()
  end

  defp fini(state) do
    Process.cancel_timer(state.timer)
    flush_ticks()
    UI.fini(state)
  end

  defp flush_ticks() do
    # This cleans up our mailbox since snake is often invoked from the IEx console's process
    # rather than a process we can kill and have Erlang cleanup after us.
    receive do
      :tick -> flush_ticks()
    after
      500 -> :ok
    end
  end

  def run() do
    %Snake.State{}
    |> init()
    |> UI.draw_screen()
    |> schedule_next_tick()
    |> loop()
    |> fini()

    :ok
  end

  def loop(%{game_over: true} = state) do
    UI.game_over(state)
  end

  def loop(state) do
    next_state =
      receive do
        {:ex_ncurses, :key, key} ->
          Logger.debug("Got key #{key} or '#{<<key>>}''")
          handle_key(state, key)

        :tick ->
          state
          |> run_turn()
          |> UI.draw_screen()
          |> schedule_next_tick()
      end

    loop(next_state)
  end

  # vim
  defp handle_key(state, ?h), do: %{state | direction: :left}
  defp handle_key(state, ?k), do: %{state | direction: :up}
  defp handle_key(state, ?j), do: %{state | direction: :down}
  defp handle_key(state, ?l), do: %{state | direction: :right}

  # wasd
  defp handle_key(state, ?w), do: %{state | direction: :up}
  defp handle_key(state, ?a), do: %{state | direction: :left}
  defp handle_key(state, ?s), do: %{state | direction: :down}
  defp handle_key(state, ?d), do: %{state | direction: :right}

  # arrows
  defp handle_key(state, 259), do: %{state | direction: :up}
  defp handle_key(state, 260), do: %{state | direction: :left}
  defp handle_key(state, 258), do: %{state | direction: :down}
  defp handle_key(state, 261), do: %{state | direction: :right}

  defp handle_key(state, ?q), do: %{state | game_over: true}
  defp handle_key(state, _), do: state

  defp schedule_next_tick(state) do
    timer = Process.send_after(self(), :tick, @tick)
    %{state | timer: timer}
  end

  defp run_turn(state) do
    next_head = next_snake_head(state.snake, state.direction)

    cond do
      loses(state, next_head) ->
        %{state | game_over: true}

      hits_food(state, next_head) ->
        state
        |> grow_snake(next_head)
        |> place_food()
        |> incr_score()

      true ->
        state
        |> move_snake(next_head)
    end
  end

  defp place_snake(state) do
    snake = [{div(state.width, 2), div(state.height, 2)}]
    %{state | snake: snake}
  end

  defp grow_snake(state, next_head) do
    new_snake = [next_head | state.snake]
    %{state | snake: new_snake}
  end

  defp incr_score(state), do: %{state | score: state.score + 1}

  defp move_snake(state, next_head) do
    trimmed = Enum.reverse(state.snake) |> tl() |> Enum.reverse()
    %{state | snake: [next_head | trimmed]}
  end

  defp place_food(state) do
    location = {:rand.uniform(state.width - 2), :rand.uniform(state.height - 3)}

    if hits_snake(state.snake, location) do
      place_food(state)
    else
      %{state | food: location}
    end
  end

  defp loses(state, next_head) do
    hits_wall(state, next_head) || hits_snake(state.snake, next_head)
  end

  defp hits_wall(_state, {0, _y}), do: true
  defp hits_wall(_state, {_x, 0}), do: true
  defp hits_wall(%{width: width} = _state, {x, _y}) when x == width - 1, do: true
  defp hits_wall(%{height: height} = _state, {_x, y}) when y == height - 2, do: true
  defp hits_wall(_state, _snake_head), do: false

  defp hits_food(%{food: location} = _state, location), do: true
  defp hits_food(_state, _snake_head), do: false

  defp hits_snake(snake, location) do
    Enum.member?(snake, location)
  end

  defp next_snake_head([{x, y} | _] = _snake, :up), do: {x, y - 1}
  defp next_snake_head([{x, y} | _] = _snake, :down), do: {x, y + 1}
  defp next_snake_head([{x, y} | _] = _snake, :left), do: {x - 1, y}
  defp next_snake_head([{x, y} | _] = _snake, :right), do: {x + 1, y}
end
