defmodule RelativeTime.MixProject do
  use Mix.Project

  def project do
    [
      app: :relative_time,
      version: "0.2.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "DSL to express absolute and relative times, similar to grafana",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/ZennerIoT/relative_time"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.6"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
