def split_first(list, divider) do
  {left, right} = Enum.split_while(list, divider)
  if right == [] do
    {list, nil}
  else
    {left, tl(right)}
  end
end

def rewrite_empty_symbol(rule_right, empty_symbol) do
  {left, right} = split_first(rule_right, &(&1 != empty_symbol))
  if right == nil do
    [rule_right]
  else
    Enum.flat_map(rewrite_empty_symbol(right, empty_symbol), &(
      [left ++ &1, left ++ [empty_symbol | &1]]
    ))
  end |> MapSet.new
end

def eliminate_empty_rules(rules, start) do
  eliminate_empty_rules({rules, start})
end

def eliminate_empty_rules({rules, start}) do
  empty_rule = Enum.find(rules, &(elem(&1, 0) != start and elem(&1, 1) == []))
  if is_nil(empty_rule) do
    rules
  else
    MapSet.delete(rules, empty_rule)
    |> Enum.flat_map(fn({rule_left, rule_right}) ->
      Enum.map(rewrite_empty_symbol(rule_right, elem(empty_rule, 0)), &({rule_left, &1}))
    end)
    |> MapSet.new
    |> eliminate_empty_rules(start)
  end
end
