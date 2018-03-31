defmodule ExDocMakeup.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_doc_makeup,
      version: "0.2.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        markdown_processor: ExDocMakeup
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    "Markdown processor for ExDoc that uses Makeup for syntax highlighting"
  end

  def package do
    [
      name: :ex_doc_makeup,
      licenses: ["BSD"],
      maintainers: ["Tiago Barroso <tmbb@campus.ul.pt>"],
      links: %{"GitHub" => "https://github.com/tmbb/ex_doc_makeup"},
      files: ["assets/dist", "config", "lib", "mix.exs", "README.md", "CHANGELOG.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18.3"},
      {:makeup, "~> 0.4.0"},
      {:makeup_elixir, "~> 0.4.0"}
    ]
  end
end
