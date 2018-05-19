defmodule ExDocMakeup.CodeRenderer do
  @moduledoc false

  alias Earmark.Block
  alias Makeup.Lexers.ElixirLexer

  @supported_lexers [
    ElixirLexer
  ]

  # By default, we assume that a code block contains Elixir code until told otherwise.
  # ExDoc is supposed to be used with Elixir projects after all.
  defp pick_lexer(nil), do: ElixirLexer
  defp pick_lexer("elixir"), do: ElixirLexer
  defp pick_lexer(other), do: other

  defp escape_html_entities(string) do
    escape_map = [{"&", "&amp;"}, {"<", "&lt;"}, {">", "&gt;"}, {~S("), "&quot;"}]
    Enum.reduce escape_map, string, fn {pattern, escape}, acc ->
      String.replace(acc, pattern, escape)
    end
  end

  def code_renderer(%Block.Code{lines: lines, language: language}) do
    # For now, remove support for lexer options
    lexer = pick_lexer(language)
    if lexer in @supported_lexers do
      # This branch doesn't need HTML entities to be escaped because
      # Makeup takes care of all the escaping.
      lines
      |> Enum.join("\n")
      |> Makeup.highlight_inner_html(lexer: lexer)
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
