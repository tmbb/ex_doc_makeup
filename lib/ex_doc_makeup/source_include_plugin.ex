defmodule ExDocMakeup.SourceIncludePlugin do
  @moduledoc false
  alias ExDocMakeup.CodeRenderer

  defp is_fragment_marker?(line, marker) do
    trimmed = String.trim_leading(line)
    String.starts_with?(trimmed, "#{marker}! begin:") or
      String.starts_with?(trimmed, "#{marker}! end:")
  end

  defp reject_fragment_markers(lines, marker) do
    Enum.reject(lines, fn line -> is_fragment_marker?(line, marker) end)
  end

  defp extract_block(file, block, marker) do
    content = File.read!(file)
    fragment = Regex.run(
      ~r/\n\s*#{marker}! begin: #{block}\n(.*)\n\s*#{marker}! end: #{block}\n/su,
      content,
      capture: :all_but_first)

    case fragment do
      [block_content | _] ->
        block_content
        |> String.split("\n")
        |> reject_fragment_markers(marker)

      _ ->
        raise "'include' directive: block '#{block}' wasn't found"
    end
  end

  defp extract_lines(file, range, marker) do
    file
    |> File.read!
    |> String.split("\n")
    |> Enum.slice(range)
    |> reject_fragment_markers(marker)
  end

  defp extract_file(file, marker) do
    file
    |> File.read!
    |> String.split("\n")
    |> reject_fragment_markers(marker)
  end

  defp execute_ast_(file, opts) when is_binary(file) do
    marker = "#"
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
    code_lines =
      case {lines, block} do
        # Valid combinations
        {nil, nil} ->
          extract_file(file, marker)

        {lines, nil} ->
          extract_lines(file, lines, marker)

        {nil, block} ->
          extract_block(file, block, marker)

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
