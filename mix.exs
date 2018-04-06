defmodule Snake.MixProject do
  use Mix.Project

  def project do
    [
      app: :snake,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_ncurses, "~> 0.3"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
