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

  def assert_same_content(a, b) do
    assert MapSet.new(a) == MapSet.new(b)
  end

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
    assert_same_content(eliminate_nonsolitary_terminal({[
      {"A", ["B"]},
      {"A", ["a"]},
      {"B", ["b"]},
      {"B", ["B", "b"]},
      {"B", ["b", "+", "b"]},
    ], nil}),
    [
      {"A", ["B"]},
      {"A", ["a"]},
      {"B", ["b"]},
      {"N_B", ["b"]},
      {"B", ["B", "N_B"]},
      {"N_+", ["+"]},
      {"B", ["N_B", "N_+", "N_B"]},
    ])
  end
end
