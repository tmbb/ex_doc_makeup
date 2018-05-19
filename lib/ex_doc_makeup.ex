defmodule ExDocMakeup do
  @moduledoc """
  ExDoc-compliant markdown processor using [Makeup](https://github.com/tmbb/makeup) for syntax highlighting.

  This package is optimized to be used with ExDoc, and not alone by itself.
  It's just [Earmark](https://github.com/pragdave/earmark)
  customized to use Makeup as a syntax highlighter plus some functions to make it
  play well with ExDoc.
  """
  alias Makeup.Formatters.HTML.HTMLFormatter
  alias ExDocMakeup.CodeRenderer

  @behaviour ExDoc.Markdown

  @external_resource "assets/dist/ex_doc_makeup.css"

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
    processed_options = for {lexer, opts} <- lexer_options, into: %{}, do: {lexer, opts}
    Application.put_env(:ex_doc_makeup, :config_options, processed_options)
  end

  def available? do
    true
  end

  # Internal details
  defp as_html!(source, options) do
    Earmark.as_html!(source,
      %{options | render_code: &CodeRenderer.code_renderer/1,})
  end

  # TODO: Generalize this to more languages.
  defp hljs_proof_code(html) do
    html
    |> String.replace("<pre><code>", "<pre><code class=\"nohighlight makeup\">")
    |> String.replace("<pre><code class=\"elixir\">", "<pre><code class=\"nohighlight makeup\">")
  end
end
