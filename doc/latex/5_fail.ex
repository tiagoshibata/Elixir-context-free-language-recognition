def eliminate_unit_rules(rules) do
  unit_rule = Enum.find(rules, fn({_, rule_right}) ->
    length(rule_right) == 1 and not is_terminal(hd(rule_right))
  end)
  if is_nil(unit_rule) do
    rules
  else
    {unit_left, [unit_right]} = unit_rule
    Enum.filter(rules, &(elem(&1, 0) == unit_right))
    |> Enum.map(fn({^unit_right, rule_right}) -> {unit_left, rule_right} end)
    |> MapSet.new
    |> MapSet.union(rules)
    |> MapSet.delete(unit_rule)
    |> eliminate_unit_rules
  end
end
