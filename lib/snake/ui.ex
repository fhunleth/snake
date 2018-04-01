defmodule Snake.UI do
  require Logger

  def init(state) do
    ExNcurses.initscr()

    win = ExNcurses.newwin(state.height - 1, state.width, 1, 0)
    ExNcurses.listen()
    ExNcurses.noecho()
    ExNcurses.keypad()
    ExNcurses.curs_set(0)

    %{state | game_win: win}
  end

  def fini(state) do
    ExNcurses.stop_listening()
    ExNcurses.endwin()
    state
  end

  def game_over(state) do
    center_text(state, " GAME OVER ")
    ExNcurses.refresh()
    flush_input()

    receive do
      {:ex_ncurses, :key, _} -> state
    end
  end

  def flush_input() do
    receive do
      {:ex_ncurses, :key, _} -> flush_input()
    after
      100 -> :ok
    end
  end

  def draw_screen(state) do
    ExNcurses.clear()
    ExNcurses.mvaddstr(0, 2, "Snake")
    ExNcurses.wclear(state.game_win)
    ExNcurses.wborder(state.game_win)
    update_score(state)
    draw_snake(state, state.snake)
    draw_food(state)
    ExNcurses.refresh()
    ExNcurses.wrefresh(state.game_win)
    state
  end

  defp draw_food(state) do
    {x, y} = state.food
    ExNcurses.wmove(state.game_win, y, x)
    ExNcurses.waddstr(state.game_win, "*")
    state
  end

  defp draw_snake(state, []), do: state

  defp draw_snake(state, [{x, y} | rest]) do
    ExNcurses.wmove(state.game_win, y, x)
    ExNcurses.waddstr(state.game_win, "#")
    draw_snake(state, rest)
  end

  defp center_text(state, str) do
    y = div(state.height, 2)
    x = div(state.width - String.length(str), 2)
    ExNcurses.mvaddstr(y, x, str)
  end

  def update_score(state) do
    ExNcurses.mvaddstr(0, state.width - 20, "Score: #{state.score}")
    state
  end
end
