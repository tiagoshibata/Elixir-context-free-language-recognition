test "checks for terminals" do
  assert is_terminal("+")
  assert is_terminal("a")
  assert is_terminal("0")
  assert not is_terminal("A")
  assert not is_terminal("VB")
  assert not is_terminal("N_A")
  assert not is_terminal("N_+")
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
