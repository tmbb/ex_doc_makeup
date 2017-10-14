defmodule ExDocMakeup.SourceIncludePlugin do
  @moduledoc false
  alias ExDocMakeup.CodeRenderer

  defp extract_block(file, block, marker) do
    content = File.read!(file)
    case Regex.run(~r/\n\s*#{marker} !begin: #{block}\n(.*)\n\s*#{marker} !end: #{block}\n/su,
                   content,
                   capture: :all_but_first) do
      [ block_content | _] -> String.split(block_content, "\n")
      _ -> raise "'include' directive: block wasn't found"
    end
  end

  defp extract_lines(file, range) do
    file
    |> File.read!
    |> String.split("\n")
    |> Enum.slice(range)
  end

  defp execute_ast_(file, opts) when is_binary(file) do
    # Get language from options; default is "elixir"
    lang = Keyword.get(opts, :lang, "elixir")
    # Get lines from options
    line_range_ast = Keyword.get(opts, :lines, nil)
    lines = case line_range_ast do
      {:.., _, [min, max]} -> min..max
      nil -> nil
      _ -> raise "'include' directive: invalid value for `lines`"
    end
    # Get block from options
    block = Keyword.get(opts, :block, nil)
    # Should we keep indent?
    _trim = Keyword.get(opts, :dedent, false)
    # Extract the lilnes of code from the file
    code_lines = case {lines, block} do
      # Valid combinations
      {nil, nil} ->
        # Get the whole file
        file |> File.read! |> String.split("\n")
      {lines, nil} ->
        extract_lines(file, lines)
      {nil, block} ->
        extract_block(file, block, "#")
      # Invalid combination
      {_lines, _block} ->
        raise "'include' directive: can't give both `lines` and `block` options."
    end

    CodeRenderer.code_block_renderer(code_lines, lang)
  end

  defp execute_ast({:include, _, [file, opts]}), do: execute_ast_(file, opts)
  defp execute_ast({:include, _, [file]}), do: execute_ast_(file, [])
  defp execute_ast(_), do: raise "'include' directive: couldn't parse directive"

  defp execute_line(line) do
    case Code.string_to_quoted(line) do
      {:ok, ast} -> execute_ast(ast)
      :error -> raise "SourceInclude plugin: Invalid syntax!"
    end
  end

  def as_html(lines) do
    Enum.map(lines, fn {line, _} -> execute_line(line) end)
  end

end