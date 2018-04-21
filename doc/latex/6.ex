def to_chomsky_nf({rules, start}) do
  {rules, start} = eliminate_right_start({rules, start})
  rules = eliminate_nonsolitary_terminal(rules)
  |> eliminate_right_side_with_multiple_nonterminals
  |> eliminate_empty_rules(start)
  |> eliminate_unit_rules
  {rules, start}
end
