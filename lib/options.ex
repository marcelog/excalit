defmodule Options do
  def validate(argv, required) do
    {opts, _flags} = OptionParser.parse argv
    Enum.each required, fn(x) ->
      if undefined? x, opts do
        raise "Need the --#{x} option"
      end
    end  
    opts
  end

  def undefined?(option, options) do
    false == :proplists.is_defined option, options
  end

  def get(option, options) do
    :proplists.get_value option, options
  end

  def get(option, options, default) do
    :proplists.get_value option, options, default
  end
end