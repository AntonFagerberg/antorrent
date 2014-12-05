defmodule Bencode do
  def decode!(data) do
    case decode_p(data) do
      {result, ""} -> result
      {_, tail} -> raise("Unparsed trailing data: #{tail}")
    end
  end

  def decode(data) do
    case decode_p(data) do
      {result, ""} -> {:ok, result}
      {_, tail} -> {:error, tail}
    end
  end

  defp decode_p("l" <> rest), do: decode_p(rest, [])
  defp decode_p("d" <> rest), do: decode_p(rest, %{})

  defp decode_p("i" <> rest) do
    int_pattern = ~r/(?<num>^(-?[1-9]+[1-9]*|[0-9]+))e(?<tail>.*)/

    %{"num" => num, "tail" => tail} = Regex.named_captures(int_pattern, rest)
    {int, _} = Integer.parse(num)

    {int, tail}
  end

  defp decode_p(data) do
    %{"size" => size} = Regex.named_captures(~r/^(?<size>[0-9]+):/, data)
    {int_size, _} = Integer.parse(size)
    
    {_, data} = String.split_at(data, String.length(size) + 1)
    String.split_at(data, int_size)
  end


  defp decode_p("e" <> rest, acc) when is_list(acc), do: {Enum.reverse(acc), rest}
  defp decode_p("e" <> rest, acc), do: {acc, rest}

  defp decode_p(rest, acc) when is_list(acc) do
    {value, tail} = decode_p(rest)
    decode_p(tail, [value | acc])
  end

  defp decode_p(rest, acc) when is_map(acc) do
    {key, key_tail} = decode_p(rest)
    {value, tail} = decode_p(key_tail)
    decode_p(tail, Map.put(acc, key, value))
  end
end
