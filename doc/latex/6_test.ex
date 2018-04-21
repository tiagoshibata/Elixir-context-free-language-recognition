test "generates the Chomsky normal form" do
  math_rules = MapSet.new [
    {"EXPR", ["TERM"]},
    {"EXPR", ["EXPR", "ADD", "TERM"]},
    {"EXPR", ["ADD", "TERM"]},
    {"TERM", ["FACTOR"]},
    {"TERM", ["TERM", "MUL", "FACTOR"]},
    {"FACTOR", ["PRIMARY"]},
    {"FACTOR", ["FACTOR", "^", "PRIMARY"]},
    {"PRIMARY", ["number"]},
    {"PRIMARY", ["variable"]},
    {"PRIMARY", ["(", "EXPR", ")"]},
    {"ADD", ["+"]},
    {"ADD", ["-"]},
    {"MUL", ["*"]},
    {"MUL", ["/"]},
  ]
  {new_rules, new_start} = eliminate_right_start({math_rules, "EXPR"})
  assert {new_rules, new_start} == {MapSet.put(math_rules, {"S0", ["EXPR"]}), "S0"}

  new_rules = eliminate_nonsolitary_terminal(new_rules)
  assert new_rules == MapSet.new [
    {"S0", ["EXPR"]},
    {"EXPR", ["TERM"]},
    {"EXPR", ["EXPR", "ADD", "TERM"]},
    {"EXPR", ["ADD", "TERM"]},
    {"TERM", ["FACTOR"]},
    {"TERM", ["TERM", "MUL", "FACTOR"]},
    {"FACTOR", ["FACTOR", "N_^", "PRIMARY"]},
    {"FACTOR", ["PRIMARY"]},
    {"PRIMARY", ["number"]},
    {"PRIMARY", ["variable"]},
    {"PRIMARY", ["N_(", "EXPR", "N_)"]},
    {"N_(", ["("]},
    {"N_)", [")"]},
    {"N_^", ["^"]},
    {"ADD", ["+"]},
    {"ADD", ["-"]},
    {"MUL", ["*"]},
    {"MUL", ["/"]},
  ]

    new_rules = eliminate_right_side_with_multiple_nonterminals(new_rules)
  assert new_rules == MapSet.new [
    {"S0", ["EXPR"]},
    {"EXPR", ["TERM"]},
    {"EXPR", ["EXPR", "EXPR_1"]},
    {"EXPR_1", ["ADD", "TERM"]},
    {"EXPR", ["ADD", "TERM"]},
    {"TERM", ["FACTOR"]},
    {"TERM", ["TERM", "TERM_1"]},
    {"TERM_1", ["MUL", "FACTOR"]},
    {"FACTOR", ["FACTOR", "FACTOR_1"]},
    {"FACTOR_1", ["N_^", "PRIMARY"]},
    {"FACTOR", ["PRIMARY"]},
    {"PRIMARY", ["number"]},
    {"PRIMARY", ["variable"]},
    {"PRIMARY", ["N_(", "PRIMARY_1"]},
    {"PRIMARY_1", ["EXPR", "N_)"]},
    {"N_(", ["("]},
    {"N_)", [")"]},
    {"N_^", ["^"]},
    {"ADD", ["+"]},
    {"ADD", ["-"]},
    {"MUL", ["*"]},
    {"MUL", ["/"]},
  ]

  assert eliminate_empty_rules({new_rules, new_start}) == new_rules

  new_rules = eliminate_unit_rules(new_rules)
  expected_rules = MapSet.new [
    {"S0", ["FACTOR", "FACTOR_1"]},
    {"S0", ["number"]},
    {"S0", ["variable"]},
    {"S0", ["N_(", "PRIMARY_1"]},
    {"S0", ["TERM", "TERM_1"]},
    {"S0", ["EXPR", "EXPR_1"]},
    {"S0", ["ADD", "TERM"]},
    {"EXPR", ["FACTOR", "FACTOR_1"]},
    {"EXPR", ["number"]},
    {"EXPR", ["variable"]},
    {"EXPR", ["N_(", "PRIMARY_1"]},
    {"EXPR", ["TERM", "TERM_1"]},
    {"EXPR", ["EXPR", "EXPR_1"]},
    {"EXPR_1", ["ADD", "TERM"]},
    {"EXPR", ["ADD", "TERM"]},
    {"TERM", ["FACTOR", "FACTOR_1"]},
    {"TERM", ["number"]},
    {"TERM", ["variable"]},
    {"TERM", ["N_(", "PRIMARY_1"]},
    {"TERM", ["TERM", "TERM_1"]},
    {"TERM_1", ["MUL", "FACTOR"]},
    {"FACTOR", ["FACTOR", "FACTOR_1"]},
    {"FACTOR_1", ["N_^", "PRIMARY"]},
    {"FACTOR", ["number"]},
    {"FACTOR", ["variable"]},
    {"FACTOR", ["N_(", "PRIMARY_1"]},
    {"PRIMARY", ["number"]},
    {"PRIMARY", ["variable"]},
    {"PRIMARY", ["N_(", "PRIMARY_1"]},
    {"PRIMARY_1", ["EXPR", "N_)"]},
    {"N_(", ["("]},
    {"N_)", [")"]},
    {"N_^", ["^"]},
    {"ADD", ["+"]},
    {"ADD", ["-"]},
    {"MUL", ["/"]},
    {"MUL", ["*"]},
  ]
  assert new_rules == expected_rules

  assert to_chomsky_nf({math_rules, "EXPR"}) == {expected_rules, "S0"}
end
