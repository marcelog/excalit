defmodule Client do
  require Net
  require Lager

  defrecord Request,
    host: nil,
    port: nil,
    path: nil,
    proto: nil,
    method: nil

  def new(id, pid, req) do
    try do
      {socket,time_con} = Prof.time fn() ->
        Net.open req.host, req.port
      end
      notify id, pid, {:time_con, time_con}

      {_,time_send} = Prof.time fn() ->
        Net.send socket, build_request req
      end
      notify id, pid, {:time_send, time_send}

      {data,time_recv} = Prof.time fn() ->
        Net.recv socket
      end
      lines = String.split String.strip(data, "\r"), "\n"
      status_line = hd lines
      [_,status_code|_] = String.split status_line, " "
      notify id, pid, {
        :time_recv, time_recv, size(data),
        list_to_integer(binary_to_list(status_code))
      }
      notify id, pid, {:ok}

      Net.close socket
    rescue
      error -> notify id, pid, {:error, error}
    catch
      error -> notify id, pid, {:error, error}
    end
  end

  def build_request(req) do
    method = case String.downcase req.method do
      "get" -> 'GET'
      "post" -> 'POST'
      "put" -> 'PUT'
      "delete" -> 'DELETE'
      "head" -> 'HEAD'
      "options" -> 'OPTIONS'
      "trace" -> 'TRACE'
      "connect" -> 'CONNECT'
      x -> throw 'invalid method: #{x}'
    end
    '#{method} ' ++
    case req.path do
      nil -> '/ '
      _ -> '#{req.path} '
    end ++
    case req.proto do
      :http11 -> 'HTTP/1.1\r\nhost: #{req.host}\r\n'
      :http10 -> 'HTTP/1.0\r\n'
      x -> throw 'invalid proto: #{x}'
    end ++
    '\r\n'
  end

  def notify(id, pid, msg) do
    pid <- {id, msg}
  end
end
