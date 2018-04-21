def unit_rules_reachable_from(rules, from) do
  unit_rules = Enum.filter(rules, fn({rule_left, rule_right}) ->
    rule_left == from and length(rule_right) == 1 and not is_terminal(hd(rule_right))
  end)
  expanded_unit_rules = Enum.filter(rules, &Enum.any?(unit_rules, fn({_, [unit_right]}) -> elem(&1, 0) == unit_right end))
  |> Enum.map(fn({_, rule_right}) -> {from, rule_right} end)
  |> MapSet.new
  |> MapSet.union(rules)
  if expanded_unit_rules == rules do
    rules
  else
    unit_rules_reachable_from(expanded_unit_rules, from)
  end |> MapSet.difference(MapSet.new unit_rules)
end

def eliminate_unit_rules(rules) do
  Enum.reduce(Enum.map(rules, &elem(&1, 0)) |> Enum.uniq, rules, fn(rule, acc) ->
    unit_rules_reachable_from(acc, rule)
  end)
end
