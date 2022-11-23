defmodule ExMachinaMongo.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_machina_mongo,
      version: "0.0.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/carlosliracl/ex_machina_mongo"
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
      {:ex_machina, "~> 2.0"},
      {:poison, "~> 2.0"},
      {:mongodb_driver, "~> 0.9.1", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Just some lines of code to make ex_machina work with the Repo module present in the elixir-mongodb-driver"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/carlosliracl/ex_machina_mongo"}
    ]
  end
end
