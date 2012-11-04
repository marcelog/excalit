defmodule Excalit do
  require Lager
  require Options
  require Net

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
      show_results(wait_clients concurrent)
    end
    Lager.info "Total: ~p us", [time]
  end

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

  def wait_clients(total) do
    wait_clients total, [
      success: 0,
      error: 0,
      time_con: [],
      time_recv: []
    ]
  end

  def wait_clients(0, acc) do
    acc
  end

  # Collects messages sent by each client and creates a result of the run.
  def wait_clients(total, acc) do
    {left, result} = receive do
      {x, {:ok}} ->
        # Client finished ok, increment success counter
        Lager.info '#{x}: Finished'
        n = :proplists.get_value :success, acc
        {total - 1, :lists.keyreplace(:success, 1, acc, {:success, n+1})}

      {x, {:error, error}} ->
        # Client finished with errors, increment error counter
        n = :proplists.get_value :success, acc
        Lager.error '#{x}: Error: ~p', [error]
        {total - 1,  :lists.keyreplace(:error, 1, acc, {:error, n+1})}

      {x, {:time_con, time}} ->
        # Client not finished, add connection time to results
        Lager.info '#{x}: open: ~p us', [time]
        n = :proplists.get_value :time_con, acc
        times = :lists.keystore(x, 1, n, {x, time})
        {total, :lists.keystore(:time_con, 1, acc, {:time_con, times})}

      {x, {:time_send, time}} ->
        # We don't care about this one
        Lager.info '#{x}: send: ~p us', [time]
        {total, acc}

      {x, {:time_recv, time, data_len, status}} ->
        # Client not finished, add receive time to results
        Lager.info '#{x}: recv: ~p|~p|~p us', [status, data_len, time]
        n = :proplists.get_value :time_recv, acc
        times = :lists.keystore(x, 1, n, {x, time})
        {total, :lists.keystore(:time_recv, 1, acc, {:time_recv, times})}
    end
    wait_clients left, result
  end

  def start_apps() do
    Enum.each [:compiler, :syntax_tools, :lager, :exlager], fn(x) ->
      :application.start x
    end
  end

  def process_times(description, times) do
    times_sorted = :lists.sort(fn({_,t1}, {_,t2}) ->
        t1 <= t2
      end,
      times
    )
    total = length times_sorted
    {id1,best} = hd times_sorted
    {id2,worst} = :lists.nth total, times_sorted
    Lager.info '#{description} best: ~p: ~p us', [id1, best]
    Lager.info '#{description} worst: ~p: ~p us', [id2, worst]
  end

  def show_results(results) do
    process_times "TCP connect time", :proplists.get_value(:time_con, results)
    process_times "Recv data", :proplists.get_value(:time_recv, results)
  end

end
