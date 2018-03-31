defmodule ExDocMakeup.CodeRenderer do
  @moduledoc false

  alias Earmark.Block

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

  # !begin: get_options
  # Get the options from the app's environment
  defp get_options() do
    Application.get_env(:ex_doc_makeup, :config_options, %{})
  end
  # !end: get_options

  def code_renderer(%Block.Code{lines: lines, language: language}) do
    # options = ExDoc.Markdown.get_markdown_processor_options()
    lang = pick_language(language)
    lexer_options = Map.get(get_options(), lang, [])
    if lang in @supported_languages do
      # This branch doesn't need HTML entities to be escaped because
      # Makeup takes care of all the escaping.
      lines
      |> Enum.join("\n")
      |> Makeup.highlight_inner_html(lexer: lang, lexer_options: lexer_options)
    else
      # In this branch, the text is included "raw", so we need to escape.
      lines
      |> Enum.join("\n")
      |> escape_html_entities
    end
  end

  def code_block_renderer(lines, language) do
    inner = code_renderer(%Block.Code{lines: lines, language: language})
    """
    <pre><code class="nohighlight makeup #{language}">#{inner}</code></pre>
    """
  end
end
