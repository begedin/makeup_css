defmodule MakeupCSS.MixProject do
  use Mix.Project

  @version "0.2.2"

  @url "https://github.com/begedin/makeup_css"
  def project do
    [
      app: :makeup_css,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Package
      package: package(),
      description: description(),
      aliases: [],
      docs: docs()
    ]
  end

  defp description do
    """
    CSS lexer for the Makeup syntax highlighter.
    """
  end

  defp package do
    [
      maintainers: ["Nikola Begedin"],
      licenses: ["MIT"],
      links: %{"GitHub" => @url},
      files: ~w(LICENSE README.md lib mix.exs .formatter.exs)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [],
      deps: deps(),
      mod: {MakeupCSS.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.1"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  def docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      main: "readme"
    ]
  end
end
