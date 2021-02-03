defmodule RelativeTime.Calculations do
  @datetime_units ~w[year month day hour minute second millisecond]a

  @spec trunc(DateTime.t(), RelativeTime.edge(), RelativeTime.unit()) :: DateTime.t()
  def trunc(datetime, edge, unit)
  def trunc(dt, :past, :day) do
    Timex.beginning_of_day(dt)
  end
  def trunc(dt, :future, :day) do
    Timex.end_of_day(dt)
  end
  def trunc(dt, :past, :week) do
    Timex.beginning_of_week(dt)
  end
  def trunc(dt, :future, :week) do
    Timex.end_of_week(dt)
  end
  def trunc(dt, :past, :month) do
    Timex.beginning_of_month(dt)
  end
  def trunc(dt, :future, :month) do
    Timex.end_of_month(dt)
  end
  def trunc(dt, :past, :year) do
    Timex.beginning_of_year(dt)
  end
  def trunc(dt, :future, :year) do
    Timex.end_of_year(dt)
  end
  def trunc(dt, :past, :hour) do
    Timex.set(dt, minute: 0, second: 0)
    |> trunc_micro(:past)
  end
  def trunc(dt, :future, :hour) do
    Timex.set(dt, minute: 59, second: 59)
    |> trunc_micro(:future)
  end
  def trunc(dt, :past, :minute) do
    Timex.set(dt, second: 0)
    |> trunc_micro(:past)
  end
  def trunc(dt, :future, :minute) do
    Timex.set(dt, second: 59)
    |> trunc_micro(:future)
  end
  def trunc(dt, edge, :second) do
    trunc_micro(dt, edge)
  end

  @doc """
  Truncates the microsecond component of a datetime, depending on precision and
  existence already set in that datetime.
  """
  def trunc_micro(%DateTime{microsecond: nil} = dt, _), do: dt
  def trunc_micro(%DateTime{microsecond: {_, precision}} = dt, :past), do: Timex.set(dt, microsecond: {0, precision})
  def trunc_micro(%DateTime{microsecond: {_, 3}} = dt, :future), do: Timex.set(dt, microsecond: {999, 3})
  def trunc_micro(%DateTime{microsecond: {_, 6}} = dt, :future), do: Timex.set(dt, microsecond: {999_999, 6})



  @spec shift(DateTime.t(), tuple(), float()) :: DateTime.t() | {:error, any}
  def shift(datetime, interval, factor)
  def shift(datetime, {:interval, _ctx, [amount, unit]}, factor) do
    amount = amount * factor
    timex_opts = [
      {:"#{unit}s", amount}
    ]
    Timex.shift(datetime, timex_opts)
  end

  @doc """
  From a keyword list of Timex.set/2 options, returns the unit that has the most
  precision. For example, if opts was `[year: 2020, month: 2]`, month is the
  most precise unit.

  ### Examples

      iex> RelativeTime.Calculations.most_precise_unit([year: 2020])
      :year
      iex> RelativeTime.Calculations.most_precise_unit([hour: 12, minute: 30])
      :minute
  """
  def most_precise_unit(opts) do
    Enum.reduce_while(@datetime_units, nil, fn unit, acc ->
      cond do
        Keyword.has_key?(opts, unit) -> {:cont, unit}
        is_nil(acc) -> {:cont, acc}
        true -> {:halt, acc}
      end
    end)
  end
end
