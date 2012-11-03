defmodule Net do
  def open(host, port) do
    {:ok, socket} = :gen_tcp.connect \
      binary_to_list(host),
      port,
      [{:active, false}, :binary]
    socket
  end

  def send(socket, what) do
    :ok = :gen_tcp.send socket, what
  end

  def recv(socket) do
    {:ok, data} = :gen_tcp.recv socket, 0
    data
  end
end