defmodule RelativeTimeTest do
  use ExUnit.Case
  doctest RelativeTime
  doctest RelativeTime.Calculations

  # test "ast" do
  #   ast = {:/, [], [{:marker, [], "now"}, {:unit, [], "m"}]}
  #   assert RelativeTime.Runtime.eval(ast, edge: :past, markers: [now: DateTime.utc_now()])
  # end

  @origin ~U[2020-01-01T00:00:00Z]

  test "markers" do
    import RelativeTime
    assert {:ok, %DateTime{}} = from("now")
    assert {:error, {:marker_not_found, "foo"}} = from("foo")
    dt = ~U[2020-01-01T12:30:00Z]
    assert {:ok, ^dt} = from("foo", markers: [foo: dt])
  end

  test "addition" do
    import RelativeTime
    assert {:ok, ~U[2020-01-04T00:00:00Z]} = from("foo + 3d", markers: [foo: @origin])
    assert {:ok, ~U[2020-01-29T00:00:00Z]} = from("foo + 4w", markers: [foo: @origin])
    assert {:ok, ~U[2020-01-01T00:00:30Z]} = from("foo + 30s", markers: [foo: @origin])
    assert {:ok, ~U[2020-01-01T00:00:30.123Z]} = from("foo + 30s", markers: [foo: ~U[2020-01-01T00:00:00.123Z]])
  end

  test "subtraction" do
    import RelativeTime
    assert {:ok, ~U[2019-12-01T00:00:00Z]} = from("foo - 1M", markers: [foo: @origin])
  end

  test "trunc" do
    import RelativeTime
    assert {:ok, ~U[2019-01-01T00:00:00Z]} = from("foo - 1y/y", markers: [foo: @origin])
    assert {:ok, ~U[2019-12-01T00:00:00Z]} = from("foo - 1M/M", markers: [foo: @origin])
    assert {:ok, ~U[2019-12-31T00:00:00Z]} = from("foo - 1d/d", markers: [foo: @origin])
    assert {:ok, ~U[2019-12-31T23:00:00Z]} = from("foo - 1h/h", markers: [foo: @origin])
  end

  test "smart trunc" do
    import RelativeTime
    assert {:ok, ~U[2019-12-08T00:00:00Z]} = to("(foo-1M)/M+1w", markers: [foo: @origin])
  end

  test "absolute input" do
    import RelativeTime
    assert {:ok, ~U[2020-01-01T12:30:00Z]} = from("12:30", markers: [now: @origin], default_timezone: "Z")

    assert {:ok, res} = from("12:30", markers: [now: @origin], default_timezone: "Europe/Berlin")
    assert DateTime.compare(~U[2020-01-01T11:30:00Z], res) == :eq

    assert {:ok, res} = from("00:14:23", markers: [now: @origin], default_timezone: "Europe/Berlin")
    assert DateTime.compare(~U[2019-12-31T23:14:23Z], res) == :eq

    assert {:ok, ~U[2020-01-01T00:00:00Z]} = from("2020", markers: [now: @origin], default_timezone: "Z")
    assert {:ok, ~U[2020-12-31T23:59:59Z]} = to("2020", markers: [now: @origin], default_timezone: "Z")

    assert {:ok, res} = from("2020", markers: [now: @origin], default_timezone: "Europe/Berlin")
    assert DateTime.compare(~U[2019-12-31T23:00:00Z], res) == :eq

    assert {:ok, res} = to("2020", markers: [now: @origin], default_timezone: "Europe/Berlin")
    assert DateTime.compare(~U[2020-12-31T22:59:59Z], res) == :eq

    assert {:ok, ~U[2020-12-01T00:00:00.000000Z]} = from("2020-12")
    assert {:ok, ~U[2020-12-31T23:59:59.999999Z]} = to("2020-12")
    assert {:ok, ~U[2020-12-13T00:00:00.000000Z]} = from("2020-12-13")
  end

  test "parser" do
    import RelativeTime.Runtime, only: [parse: 1]
    assert {:ok, _} = parse("now-5m/m")
    assert {:error, _} = parse("5m + 1w")
  end
end
