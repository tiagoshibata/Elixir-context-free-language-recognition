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
