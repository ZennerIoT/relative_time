defmodule RelativeTime.Runtime do
  alias RelativeTime.Calculations

  @trunc_units ~w[year month week day hour minute second]a

  def parse(input) when is_binary(input) do
    with {:ok, tokens} <- RelativeTime.Tokenizer.tokenize(input),
         {:ok, ast} <- :relative_time_parser.parse(tokens) do
      {:ok, ast}
    else
      {:error, list} when is_list(list) ->
        {:error, list}

      {:error, {line, :relative_time_parser, [msg, token] = text}} ->
        formatted =
          :relative_time_parser.format_error(text)
          |> :erlang.iolist_to_binary()

        token = :erlang.iolist_to_binary(token)

        with {:ok, parsed_token} <- :erl_eval.eval_str(token <> ".\n") do
          ctx = elem(parsed_token, 2)
          make_error(formatted, ctx)
        else
          _ ->
            make_error("while parsing line #{line}: #{formatted}", line: line)
        end
    end
  end

  @spec eval(Macro.t(), RelativeTime.options()) :: {:ok, any()} | {:error, any()}
  def eval({:/, _, [datetime, unit]} = ast, context) do
    edge = get_edge(context)
    timezone = Keyword.get(context, :default_timezone, "UTC")

    with {:ok, datetime} <- eval(datetime, inc(context)),
         {:ok, unit} <- eval(unit, inc(context)),
         %DateTime{} = datetime <- Timex.Timezone.convert(datetime, timezone) do
      Calculations.trunc(datetime, edge, unit) |> timex_result(ast)
    end
  end

  def eval({:+, _, [datetime, interval]} = ast, context) do
    with {:ok, datetime} <- eval(datetime, inc(context)),
         {:ok, interval} <- eval(interval, inc(context)) do
      Calculations.shift(datetime, interval, +1) |> timex_result(ast)
    end
  end

  def eval({:-, _, [datetime, interval]} = ast, context) do
    with {:ok, datetime} <- eval(datetime, inc(context)),
         {:ok, interval} <- eval(interval, inc(context)) do
      Calculations.shift(datetime, interval, -1) |> timex_result(ast)
    end
  end

  def eval({:marker, ctx, [name]}, context) do
    markers = Keyword.get(context, :markers, now: Calculations.now(context))

    case Enum.find(markers, fn {key, _value} ->
           to_string(key) == to_string(name)
         end) do
      nil -> make_error("marker not found: #{name}", ctx)
      {_, %DateTime{} = dt} -> {:ok, dt}
      {key, other} -> make_error("invalid marker: #{key}=#{inspect(other)}", ctx)
    end
  end

  def eval(unit, _context) when unit in @trunc_units do
    {:ok, unit}
  end

  def eval({:interval, _, [amount, unit]} = interval, _context)
      when is_integer(amount) and is_atom(unit) do
    {:ok, interval}
  end

  def eval({:set_date, _, [opts]}, context) do
    edge = get_edge(context)
    tz = Keyword.get(context, :default_timezone)

    with {:ok, now} <- eval({:marker, [], ["now"]}, inc(context)),
         %DateTime{} = now_tz <- Timex.Timezone.convert(now, tz),
         most_precise_unit = Calculations.most_precise_unit(opts),
         %DateTime{} = set <- Timex.set(now_tz, opts),
         %DateTime{} = truncated <- Calculations.trunc(set, edge, most_precise_unit) do
      {:ok, truncated}
    end
  end

  def eval(%DateTime{} = dt, _context) do
    {:ok, dt}
  end

  def eval({fun, ctx, args}, _context) do
    make_error("invalid call to #{fun}/#{length(args)}", ctx)
  end

  @spec timex_result({:error, any} | {:ok, any} | any, Macro.t()) ::
          {:ok, any} | {:error, any, Macro.t()}
  defp timex_result({:error, error}, ast), do: {:error, error, ast}
  defp timex_result({:ok, value}, _ast), do: {:ok, value}
  defp timex_result(value, _ast), do: {:ok, value}

  defp get_edge(context) do
    case Keyword.get(context, :level, 0) do
      0 -> Keyword.get(context, :edge)
      _ -> :past
    end
  end

  defp inc(context) do
    Keyword.update(context, :level, 0, &(&1 + 1))
  end

  def extract_token_from_list(opts) do
    Enum.map(opts, fn {key, {_token, _line, value}} -> {key, value} end)
  end

  def make_error(msg, ctx) do
    as_text = [RelativeTime.Tokenizer.render_pos(ctx), msg]
    {:error, [context: ctx, msg: msg, formatted: as_text]}
  end
end
