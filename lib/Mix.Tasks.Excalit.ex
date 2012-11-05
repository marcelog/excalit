defmodule Mix.Tasks.Excalit do
  def run(_) do
    :ok = Application.start :excalit
    Excalit.run
  end
end