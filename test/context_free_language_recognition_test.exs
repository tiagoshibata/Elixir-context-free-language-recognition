defmodule ContextFreeLanguageRecognitionTest do
  use ExUnit.Case
  import ContextFreeLanguageRecognition
  doctest ContextFreeLanguageRecognition

  test "checks for terminals" do
    assert is_terminal("+")
    assert is_terminal("a")
    assert is_terminal("0")
    assert not is_terminal("A")
    assert not is_terminal("VB")
    assert not is_terminal("N_A")
    assert not is_terminal("N_+")
  end

  test "eliminates start symbols at the right side of rules" do
    grammar = {[], "S"}
    assert eliminate_right_start(grammar) == grammar

    rules = [{"S", ["A"]}, {"A", ["a"]}, {"A", ["B", "C"]}, {"B", ["b"]}, {"C", ["c"]}]
    grammar = {rules, "S"}
    # Should be unchanged if no start symbols in the right side
    assert eliminate_right_start(grammar) == grammar

    # Should work with MapSet
    rules = MapSet.new [{"S", ["A"]}, {"A", ["S", "A"]}, {"A", ["a"]}]
    assert eliminate_right_start({rules, "S"}) == {MapSet.put(rules, {"S0", ["S"]}), "S0"}
  end

  test "aliases terminals as nonterminals" do
    assert terminal_alias_nonterminal_rule("+") == {"N_+", ["+"]}
  end

  test "replaces solitary terminals" do
    assert replace_solitary_terminals(["X", "+", "a"]) == ["X", "N_+", "N_A"]
  end

  test "rewrites rules with nonsolitary terminals" do
    assert eliminate_nonsolitary_terminal([
      {"A", ["B"]},
      {"A", ["a"]},
      {"B", ["b"]},
      {"B", ["B", "b"]},
      {"B", ["b", "+", "b"]},
      {"B", ["a", "b"]},
    ]) == MapSet.new [
      {"A", ["B"]},
      {"A", ["a"]},
      {"B", ["b"]},
      {"N_B", ["b"]},
      {"B", ["B", "N_B"]},
      {"N_+", ["+"]},
      {"B", ["N_B", "N_+", "N_B"]},
      {"N_A", ["a"]},
      {"B", ["N_A", "N_B"]},
    ]
  end

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

  test "splits first occurence of a divider" do
    assert split_first(["A"], &(&1 != "B")) == {["A"], nil}
    assert split_first(["A", "A"], &(&1 != "A")) == {[], ["A"]}
    assert split_first(["A", "B", "C"], &(&1 != "B")) == {["A"], ["C"]}
    assert split_first(["A", "B", "C", "B", "B"], &(&1 != "B")) == {["A"], ["C", "B", "B"]}
    assert split_first(["A", "B", "C", "D"], &(&1 != "D")) == {["A", "B", "C"], []}
  end

  test "rewrites empty symbols" do
    assert rewrite_empty_symbol(["A", "A"], "B") == MapSet.new [
      ["A", "A"],
    ]
    assert rewrite_empty_symbol(["A", "A"], "A") == MapSet.new [
      ["A", "A"],
      ["A"],
      [],
    ]
    assert rewrite_empty_symbol(["A", "B", "C"], "A") == MapSet.new [
      ["A", "B", "C"],
      ["B", "C"],
    ]
    assert rewrite_empty_symbol(["A", "B", "A", "C", "A", "A"], "A") == MapSet.new [
      ["A", "B", "A", "C", "A", "A"],
      ["B", "A", "C", "A", "A"],
      ["A", "B", "C", "A", "A"],
      ["A", "B", "A", "C", "A"],
      ["B", "C", "A", "A"],
      ["B", "A", "C", "A"],
      ["A", "B", "C",  "A"],
      ["A", "B", "A", "C"],
      ["B", "C", "A"],
      ["B", "A", "C"],
      ["A", "B", "C"],
      ["B", "C"],
    ]
  end

  test "eliminates empty rules" do
    assert eliminate_empty_rules(MapSet.new([
      {"S", ["A", "a"]},
      {"A", ["a"]},
      {"A", []},
    ]), "S") == MapSet.new [
      {"S", ["A", "a"]},
      {"S", ["a"]},
      {"A", ["a"]},
    ]
    assert eliminate_empty_rules(MapSet.new([
      {"S", ["A", "b", "B"]},
      {"S", ["C"]},
      {"B", ["A", "A"]},
      {"B", ["A", "C"]},
      {"C", ["b"]},
      {"C", ["c"]},
      {"A", ["a"]},
      {"A", []},
    ]), "S") == MapSet.new [
      {"S", ["A", "b", "B"]},
      {"S", ["A", "b"]},
      {"S", ["b", "B"]},
      {"S", ["b"]},
      {"S", ["C"]},
      {"B", ["A", "A"]},
      {"B", ["A"]},
      {"B", ["A", "C"]},
      {"B", ["C"]},
      {"C", ["b"]},
      {"C", ["c"]},
      {"A", ["a"]},
    ]
  end

  test "eliminates unit rules" do
    assert eliminate_unit_rules(MapSet.new [
      {"S", ["A", "a"]},
      {"S", ["A"]},
      {"A", ["a"]},
    ]) == MapSet.new [
      {"S", ["A", "a"]},
      {"S", ["a"]},
      {"A", ["a"]},
    ]
    assert eliminate_unit_rules(MapSet.new [
      {"S", ["A", "a"]},
      {"S", ["A"]},
      {"A", ["a"]},
      {"A", ["B"]},
      {"B", ["b"]},
    ]) == MapSet.new [
      {"S", ["A", "a"]},
      {"S", ["a"]},
      {"S", ["b"]},
      {"A", ["a"]},
      {"A", ["b"]},
      {"B", ["b"]},
    ]
  end

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

  test "initializes CKY" do
    cky = init_cky({[
      {"S", ["a"]},
      {"A", ["a"]},
      {"B", ["b"]},
      {"C", ["c"]},
    ], nil}, ["a", "b", "a"])
    assert length(cky) == 3
    assert Enum.map(cky, &length/1) == [3, 3, 3]
    assert cky == [[MapSet.new(["S", "A"]), MapSet.new(["B"]), MapSet.new(["S", "A"])] | List.duplicate(MapSet.new, 3) |> List.duplicate(2)]
  end

  test "runs CKY" do
    rules = [
      {"S", ["NP", "VP"]},
      {"VP", ["VP", "PP"]},
      {"VP", ["V", "NP"]},
      {"VP", ["eats"]},
      {"PP", ["P", "NP"]},
      {"NP", ["DET", "N"]},
      {"NP", ["she"]},
      {"V", ["eats"]},
      {"P", ["with"]},
      {"N", ["fish"]},
      {"N", ["fork"]},
      {"DET", ["a"]},
    ]
    assert cky_table({rules, "S"}, ["she", "eats", "a", "fish", "with", "a", "fork"]) == [
      [
        MapSet.new(["NP"]),
        MapSet.new(["V", "VP"]),
        MapSet.new(["DET"]),
        MapSet.new(["N"]),
        MapSet.new(["P"]),
        MapSet.new(["DET"]),
        MapSet.new(["N"]),
      ],
      List.duplicate(MapSet.new, 7),
      [
        MapSet.new(["S"]),
        MapSet.new([]),
        MapSet.new(["NP"]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new(["NP"]),
        MapSet.new([]),
      ],
      List.duplicate(MapSet.new, 7),
      [
        MapSet.new([]),
        MapSet.new(["VP"]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
      ],
      List.duplicate(MapSet.new, 7),
      [
        MapSet.new(["S"]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
        MapSet.new([]),
      ]
    ]
    assert cky({rules, "S"}, ["she", "eats", "a", "fish", "with", "a", "fork"])
  end
end
