defmodule ExDocMakeup.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_doc_makeup,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      files: ["assets/dist", "config", "lib", "mix.exs", "README.md", "CHANGELOG.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, path: "../ex_doc"},
      {:makeup_elixir, "~> 0.3"}
    ]
  end
end
