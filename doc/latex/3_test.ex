test "aliases symbols as subsymbols" do
  assert subsymbol("A", 0) == "A"
  assert subsymbol("A", 1) == "A_1"
  assert subsymbol("B", 2) == "B_2"
end

test "eliminates right sides with more than two nonterminals" do
  rule = {"A", ["X1", "X2"]}
  assert eliminate_right_side_with_multiple_nonterminals(rule, 0) == MapSet.new [rule]
  rule = {"A", ["X1", "X2", "X3", "X4"]}
  new_rules = eliminate_right_side_with_multiple_nonterminals(rule, 0)
  assert Enum.all?(new_rules, fn({_, rule_right}) -> length(rule_right) == 2 end)
  assert new_rules == MapSet.new [
    {"A", ["X1", "A_1"]},
    {"A_1", ["X2", "A_2"]},
    {"A_2", ["X3", "X4"]},
  ]
  rules = [{"S", ["A", "B", "C"]}, {"A", ["B", "A", "C"]}, {"B", ["b"]}, {"C", ["c"]}]
  new_rules = eliminate_right_side_with_multiple_nonterminals(rules)
  assert Enum.all?(new_rules, fn({_, rule_right}) -> length(rule_right) <= 2 end)
  assert new_rules == MapSet.new [
    {"S", ["A", "S_1"]},
    {"S_1", ["B", "C"]},
    {"A", ["B", "A_1"]},
    {"A_1", ["A", "C"]},
    {"B", ["b"]},
    {"C", ["c"]},
  ]
end
