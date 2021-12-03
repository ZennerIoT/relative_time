defmodule RelativeTime.Tokenizer do
  @type token :: any

  def new_context() do
    [line: 1, col: 1]
  end

  @spec inc_col(binary | integer, keyword) :: keyword
  def inc_col(token, ctx) when is_binary(token) do
    inc_col(String.length(token), ctx)
  end
  def inc_col(len, ctx) when is_integer(len) do
    Keyword.update!(ctx, :col, &(&1 + len))
  end
  def inc_line(ctx) do
    ctx
    |> Keyword.put(:col, 1)
    |> Keyword.update!(:line, &(&1 + 1))
  end

  @spec tokenize(binary, keyword, [token]) :: {:ok, [token]} | {:error, any}
  def tokenize(input, ctx \\ new_context(), acc \\ [])
  def tokenize("", _, acc), do: {:ok, Enum.reverse(acc)}
  def tokenize("\n" <> rest, ctx, acc), do: tokenize(rest, inc_line(ctx), acc)
  def tokenize("\t" <> rest, ctx, acc), do: tokenize(rest, inc_col(1, ctx), acc)
  def tokenize(" " <> rest, ctx, acc), do: tokenize(rest, inc_col(1, ctx), acc)
  def tokenize("+" <> rest, ctx, acc) do
    tokenize(rest, inc_col(1, ctx), [token(:+, ctx) | acc])
  end
  def tokenize("-" <> rest, ctx, acc) do
    tokenize(rest, inc_col(1, ctx), [token(:-, ctx) | acc])
  end
  def tokenize("/" <> rest, ctx, acc) do
    tokenize(rest, inc_col(1, ctx), [token(:/, ctx) | acc])
  end
  def tokenize("(" <> rest, ctx, acc) do
    tokenize(rest, inc_col(1, ctx), [token(:"(", ctx) | acc])
  end
  def tokenize(")" <> rest, ctx, acc) do
    tokenize(rest, inc_col(1, ctx), [token(:")", ctx) | acc])
  end
  def tokenize(other, ctx, acc) do
    rules = [
      {~r/^([0-9]{4})(-[0-9]{2})?(-[0-9]{2})?[T ]?([0-9]{2})?(\:[0-9]{2})?(\:[0-9]{2})?/, fn [full | _] = matches, rest, ctx, acc ->
        parts =
          matches
          |> tl()
          |> Enum.map(&String.trim(&1, "-"))
          |> Enum.map(&String.trim(&1, ":"))
          |> Enum.map(&String.to_integer/1)
        sets = Enum.zip([:year, :month, :day, :hour, :minute, :second], parts)
        tokenize(rest, inc_col(full, ctx), [token(:set_date, ctx, sets) | acc])
      end},
      {~r/^([0-9]{2})(\:[0-9]{2})?(\:[0-9]{2})?/, fn [full | _] = matches, rest, ctx, acc ->
        parts =
          matches
          |> tl()
          |> Enum.map(&String.trim(&1, ":"))
          |> Enum.map(&String.to_integer/1)
        sets = Enum.zip([:hour, :minute, :second], parts)
        tokenize(rest, inc_col(full, ctx), [token(:set_date, ctx, sets) | acc])
      end},
      {~r/^[0-9]+/, fn [chars | _], rest, ctx, acc ->
        tokenize(rest, inc_col(chars, ctx), [token(:number, ctx, String.to_integer(chars)) | acc])
      end},
      {~r/^[a-z][a-z0-9\_]+/, fn [word | _], rest, ctx, acc ->
        tokenize(rest, inc_col(word, ctx), [token(:word, ctx, word) | acc])
      end},
      {~r/^[smhdwMy][^a-zA-Z]?/, fn [<< char::binary-1, other::binary>> | _], rest, ctx, acc ->
        tokenize(other <> rest, inc_col(1, ctx), [token(:unit, ctx, char) | acc])
      end},
    ]
    error = make_error("unknown token", other, ctx)
    Enum.reduce_while(rules, error, fn {rule, fun}, error ->
      case Regex.run(rule, other) do
        nil ->
          {:cont, error}

        [whole | _] = matches ->
          rest = String.trim_leading(other, whole)
          {:halt, fun.(matches, rest, ctx, acc)}
      end
    end)
  end

  def token(symbol, ctx) do
    {symbol, ctx[:line], ctx}
  end
  def token(symbol, ctx, args) do
    {symbol, ctx[:line], ctx, args}
  end

  def make_error(msg, rest, ctx) do
    as_text = [render_pos(ctx), msg, " before <<", rest, ">>"]
    {:error, [context: ctx, msg: msg, formatted: as_text]}
  end

  def render_pos(ctx) do
    ["line ", to_string(ctx[:line]), ", col ", to_string(ctx[:col])]
  end
end
