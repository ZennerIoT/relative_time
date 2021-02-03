# RelativeTime

## Syntax

It is possible to use relative time in 2 ways:

 1. give a more or less complete datetime string, which will simply be parsed
 2. give a relative time expression, which can reference the current time (`now`) 
    and other so called "markers", which can be defined by the application

### Data types

 * `datetime` - all markers are datetimes, and the result of the expression must 
   also be a datetime
 * `unit` - The following time units are supported: `s` (seconds), `m` (minutes), 
   `h` (hours), `d` (days), `w` (weeks), `M` (months), and `y` (years). 
 * `interval` - intervals are a duration and are represented by a number and a `unit`

### Operators

 * `datetime` + `interval` :: `datetime` 
   shifts the lhs datetime to the future by the lhs interval
 * `datetime` - `interval` :: `datetime` 
   shifts the lhs datetime into the past by the rhs interval
 * `datetime` / `unit` :: `datetime`
   Truncates the given datetime to either the start or end of the given unit, 
   depending on whether `from` or `to` was called.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `relative_time` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:relative_time, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/relative_time](https://hexdocs.pm/relative_time).

