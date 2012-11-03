defmodule Excalit do
  require Lager
  require Options
  require Net

  def launch_clients(total, url, proto, method) do
    url = URI.parse url
    me = Process.self
    Enum.each 1..total, fn(n) ->
      spawn(fn() ->
          {_,time} = Prof.time fn() ->
            req = Client.Request.new \
              host: url.host, port: url.port,
              path: url.path, proto: proto,
              method: method
            Client.new n, me, req
          end
          Lager.info '#{n}: total: ~p us', [time]
        end)
    end
  end

  def wait_clients(0) do
    :done
  end

  def wait_clients(total) do
    left = receive do
      {x, {:ok}} ->
        Lager.info '#{x}: Finished'
        total - 1
      {x, {:error, error}} ->
        Lager.error '#{x}: Error: ~p', [error]
        total - 1
      {x, {:time_con, time}} ->
        Lager.info '#{x}: open: ~p us', [time]
        total
      {x, {:time_send, time}} ->
        Lager.info '#{x}: send: ~p us', [time]
        total
      {x, {:time_recv, time, data_len, status}} ->
        Lager.info '#{x}: recv: ~p|~p|~p us', [status, data_len, time]
        total
    end
    wait_clients left
  end

  def start_apps() do
    Enum.each [:compiler, :syntax_tools, :lager, :exlager], fn(x) ->
      :application.start x
    end
  end

  def run() do
    start_apps  

    # Get needed options
    opts = Options.validate_options System.argv
    concurrent = list_to_integer(binary_to_list Options.get :concurrent, opts)
    url = Options.get :url, opts
    proto = if Options.get :http11, opts do
      :http11
    else
      :http10
    end
    method = Options.get :method, opts, "get"

    # Go!
    Lager.info "Launching: #{concurrent}"
    {_,time} = Prof.time fn() ->
      launch_clients concurrent, url, proto, method
      wait_clients concurrent
    end
    Lager.info "Total: ~p us", [time]
  end
end
