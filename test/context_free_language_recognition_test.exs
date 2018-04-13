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
    assert terminal_alias_nonterminal("+") == {"N_+", "+"}
  end
end
