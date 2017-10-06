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
  ExDoc-compliant markdown processor using [Makeup]() for syntax highlighting.

  This package is optimized to be used with ExDoc, and not alone by itself.
  It's based on [Makeup](), whihc is just [Earmark](https://github.com/pragdave/earmark).
  customized to use Makeup as a syntax highlighter.
  """
  alias Earmark.Block
  alias Makeup.Formatters.HTML.HTMLFormatter

  @behaviour ExDoc.MarkdownProcessor

  # Callback implementations
  
  @assets [
    # Read the CSS from the included file.
    # This allows us to have a custom CSS theme not included in Makeup
    # that supports both "day mode" and "night mode".
    {"dist/ex_doc_makeup.css",
     :ex_doc_makeup
       |> :code.priv_dir
       |> Path.join("/assets/ex_doc_makeup.css")
       |> File.read!},
    # Get the Javascript snippet directly from Makeup.
    # If there is any need to customize it further, we can add a "ex_doc_makeup.js" file.
    {"dist/ex_doc_makeup.js", HTMLFormatter.group_highlighter_javascript()}
  ]

  def assets(:html), do: @assets
  def assets(:epub), do: @assets

  def before_closing_head_tag(:html), do: ~S(<link rel="stylesheet" href="dist/ex_doc_makeup.css"/>)
  def before_closing_head_tag(:epub), do: ~S(<link rel="stylesheet" href="dist/ex_doc_makeup.css"/>)
  
  def before_closing_body_tag(:html), do: ~S(<script src="dist/ex_doc_makeup.js"></script>)
  def before_closing_body_tag(:epub), do: ~S(<script src="dist/ex_doc_makeup.js"></script>)

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

  # Internal details

  @supported_languages ["elixir"]

  # By default, we assume that a code block contains Elixir code until told otherwise.
  # ExDoc is supposed to be used with Elixir projects after all.
  defp pick_language(nil), do: "elixir"
  defp pick_language("elixir"), do: "elixir"
  defp pick_language(other), do: other

  defp escape_html_entities(string) do
    escape_map = [{"&", "&amp;"}, {"<", "&lt;"}, {">", "&gt;"}, {~S("), "&quot;"}]
    Enum.reduce escape_map, string, fn {pattern, escape}, acc ->
      String.replace(acc, pattern, escape)
    end
  end

  defp code_renderer(%Block.Code{lines: lines, language: language}) do
    lang = pick_language(language)
    if lang in @supported_languages do
      # This branch doesn't need HTML entities to be escaped because
      # Makeup takes care of all the escaping.
      lines
      |> Enum.join("\n")
      |> Makeup.highlight_inner_html(lexer: lang)
    else
      # In this branch, the text is included "raw", so we need to escape.
      lines
      |> Enum.join("\n")
      |> escape_html_entities
    end
  end

  defp as_html!(source, options) do
    render_code = fn block ->
      code_renderer(block)
    end
    Earmark.as_html!(source, Map.put(options, :render_code, render_code))
  end

  # TODO: Generalize this to more languages.
  defp hljs_proof_code(html) do
    html
    |> String.replace("<pre><code>", "<pre><code class=\"nohighlight makeup\">")
    |> String.replace("<pre><code class=\"elixir\">", "<pre><code class=\"nohighlight makeup\">")
  end
end
