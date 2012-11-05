defmodule Excalit.Mixfile do
  use Mix.Project

  def project do
    [ app: :excalit,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:exlager]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:exlager,%r".*",[github: "khia/exlager"]}]
  end
end
