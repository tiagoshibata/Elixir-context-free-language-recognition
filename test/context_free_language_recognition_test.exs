defmodule ContextFreeLanguageRecognitionTest do
  use ExUnit.Case
  import ContextFreeLanguageRecognition
  doctest ContextFreeLanguageRecognition

  @math_expression [
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

  test "checks for terminals" do
    assert is_terminal("+")
    assert is_terminal("a")
    assert is_terminal("0")
    assert not is_terminal("A")
    assert not is_terminal("VB")
    assert not is_terminal("N_A")
    assert not is_terminal("N_+")
  end

  test "eliminates start symbols" do
    grammar = {[], :S}
    assert eliminate_start(grammar) == grammar

    rules = [{:S, [:A]}, {:A, [:a]}, {:A, [:B, :C]}, {:B, [:b]}, {:C, [:c]}]
    grammar = {rules, :S}
    # Should be unchanged if no start symbols in the right side
    assert eliminate_start(grammar) == grammar

    # Should work with MapSet
    rules = MapSet.new [{:S, [:A]}, {:A, [:S, :A]}, {:A, [:a]}]
    assert eliminate_start({rules, :S}) == {MapSet.put(rules, {:S0, :S}), :S0}
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
    assert subsymbol('A', 0) == 'A'
    assert subsymbol('A', 1) == 'A_1'
    assert subsymbol('B', 2) == 'B_2'
  end

  test "eliminates right sides with more than two nonterminals" do
    rule = {'A', ['X1', 'X2']}
    assert eliminate_right_side_with_multiple_nonterminals(rule, 0) == MapSet.new [rule]
    rule = {'A', ['X1', 'X2', 'X3', 'X4']}
    new_rules = eliminate_right_side_with_multiple_nonterminals(rule, 0)
    assert Enum.all?(new_rules, fn({_, rule_right}) -> length(rule_right) == 2 end)
    assert new_rules == MapSet.new [
      {'A', ['X1', 'A_1']},
      {'A_1', ['X2', 'A_2']},
      {'A_2', ['X3', 'X4']},
    ]

    rules = [{'S', ['A', 'B', 'C']}, {'A', ['B', 'A', 'C']}, {'B', ['b']}, {'C', ['c']}]
    new_rules = eliminate_right_side_with_multiple_nonterminals(rules)
    assert Enum.all?(new_rules, fn({_, rule_right}) -> length(rule_right) <= 2 end)
    assert new_rules == MapSet.new [
      {'S', ['A', 'S_1']},
      {'S_1', ['B', 'C']},
      {'A', ['B', 'A_1']},
      {'A_1', ['A', 'C']},
      {'B', ['b']},
      {'C', ['c']},
    ]
  end
end
