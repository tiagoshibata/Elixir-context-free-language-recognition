def subsymbol(symbol, depth) do
  if depth == 0 do
    symbol
  else
    "#{symbol}_#{depth}"
  end
end

def eliminate_right_side_with_multiple_nonterminals({rule_left, rule_right}, depth) do
  if length(rule_right) > 2 do
    [head | tail] = rule_right
    new_rule = {subsymbol(rule_left, depth), [head, subsymbol(rule_left, depth + 1)]}
    MapSet.put eliminate_right_side_with_multiple_nonterminals({rule_left, tail}, depth + 1), new_rule
  else
    MapSet.new [{subsymbol(rule_left, depth), rule_right}]
  end
end

def eliminate_right_side_with_multiple_nonterminals(rules) do
  Enum.reduce(rules, MapSet.new, fn(rule, acc) ->
    MapSet.union(acc, eliminate_right_side_with_multiple_nonterminals(rule, 0))
  end)
end
