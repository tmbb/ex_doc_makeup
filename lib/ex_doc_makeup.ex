# Some important notes:
# - this module has been refactores into it's own package so that we can provide´
#   a simple API for ExDocs users who want to use Makeup for syntax highlighting
#   in the docs.
# - Despite the name, it doesn't actually depend on Makeup.
#   In fact, Makeup's code was copy-pasted here.
#   It's still not clear how we can make Makeup extensible, as no one is using it yet.
#   Meanwhile, ExDocMakeup will work for its simple use case and keep a simple API
#   despite changes to Makeup.
defmodule ExDocMakeup do
  @moduledoc """
  ExDoc-compliant markdown processor using [Makeup](https://github.com/tmbb/makeup) for syntax highlighting.

  This package is optimized to be used with ExDoc, and not alone by itself.
  It's just [Earmark](https://github.com/pragdave/earmark)
  customized to use Makeup as a syntax highlighter plus some functions to make it
  play well with ExDoc.
  """
  alias Makeup.Formatters.HTML.HTMLFormatter
  alias ExSpirit.TreeMap
  alias ExDocMakeup.SourceIncludePlugin
  alias ExDocMakeup.CodeRenderer

  @behaviour ExDoc.Markdown

  # Callback implementations

  @assets [
    # Read the CSS from the included file.
    # This allows us to have a custom CSS theme not included in Makeup
    # that supports both "day mode" and "night mode".
    {"dist/ex_doc_makeup-css.css", File.read!("assets/dist/ex_doc_makeup.css")},
    # Get the Javascript snippet directly from Makeup.
    # If there is any need to customize it further, we can add a "ex_doc_makeup.js" file.
    {"dist/ex_doc_makeup-js.js", HTMLFormatter.group_highlighter_javascript()}
  ]

  def assets(_), do: @assets

  def before_closing_head_tag(_), do: ~S(<link rel="stylesheet" href="dist/ex_doc_makeup-css.css"/>)

  def before_closing_body_tag(_), do: ~S(<script src="dist/ex_doc_makeup-js.js"></script>)

  def to_html(text, opts) do
    options =
      struct(Earmark.Options,
             gfm: Keyword.get(opts, :gfm, true),
             line: Keyword.get(opts, :line, 1),
             file: Keyword.get(opts, :file),
             breaks: Keyword.get(opts, :breaks, false),
             smartypants: Keyword.get(opts, :smartypants, true))
    text
    |> as_html!(options)
    |> hljs_proof_code
  end

  def configure(options) do
    lexer_options = Keyword.get(options, :lexer_options, [])
    processed_options = for {lexer, opts} <- lexer_options, into: %{} do
      case lexer do
        "elixir" -> {"elixir", process_elixir_lexer_options(opts)}
        _ -> {lexer, opts}
      end
    end

    Application.get_env(:ex_doc_makeup, :config_options, processed_options)
  end

  # Internal details

  defp tree_map_from_strings(strings) do
    Enum.reduce strings, TreeMap.new(), fn string, tree_map ->
      tree_map |> TreeMap.add_text(string, string)
    end
  end

  defp process_elixir_lexer_options(options) do
    extra_declarations =
      options
      |> Keyword.get(:extra_declarations, [])
      |> MapSet.new()

    extra_def_like =
      options
      |> Keyword.get(:extra_def_like, [])
      |> tree_map_from_strings

    [extra_declarations: extra_declarations,
      extra_def_like: extra_def_like]
  end

  defp as_html!(source, options) do
    Earmark.as_html!(source,
      %{options |
          render_code: &CodeRenderer.code_renderer/1,
          plugins: %{"" => SourceIncludePlugin}})
  end

  # TODO: Generalize this to more languages.
  defp hljs_proof_code(html) do
    html
    |> String.replace("<pre><code>", "<pre><code class=\"nohighlight makeup\">")
    |> String.replace("<pre><code class=\"elixir\">", "<pre><code class=\"nohighlight makeup\">")
  end
end
