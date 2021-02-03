defmodule RelativeTime do
  @type input :: String.t()
  @type options :: [option]
  @type option :: markers | edge_option
  @type markers :: {:markers, [marker]}
  @type edge_option :: {:edge, edge}
  @type edge :: :past | :future
  @type unit :: :second | :minute | :hour | :day | :week | :month | :year

  alias RelativeTime.Runtime

  @typedoc """
  A marker is a specific point in time that is accessible in a relative time term

  The keyword `now` is also a marker, and it is possible to set a custom `now`
  marker to override it, for testing purposes for example.
  """
  @type marker :: {atom(), DateTime.t()}

  @spec from(input, options) :: {:ok, DateTime.t()} | {:error, any()}
  def from(input, opts \\ []) do
    __run(input, Keyword.put(opts, :edge, :past))
  end

  @spec to(input, options) :: {:ok, DateTime.t()} | {:error, any()}
  def to(input, opts \\ []) do
    __run(input, Keyword.put(opts, :edge, :future))
  end

  defp __run(input, opts) do
    opts = Keyword.merge([level: 0, default_timezone: "Z"], opts)
    with {:ok, ast} <- Runtime.parse(input) do
      Runtime.eval(ast, opts)
    end
  end
end
