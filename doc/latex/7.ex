def init_cky({rules, _}, sentence) do
  first_expansion = Enum.reverse(sentence)
  |> Enum.reduce([], fn(c, acc) ->
    rules_to_c = Enum.filter(rules, &(elem(&1, 1) == [c]))
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new
    [rules_to_c | acc]
  end)

  n = length(sentence)
  [first_expansion] ++ (
    List.duplicate(MapSet.new, n)
    |> List.duplicate(n - 1)
  )
end
