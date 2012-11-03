defmodule Prof do
  require Lager
  
  def now() do
    {mega, sec, usec} = :os.timestamp()
    sec * 1000000 + mega * 1000 + usec
  end

  def time(f) do
    start = now()
    result = f.() 
    elapsed = now() - start
    {result, elapsed}
  end
end
