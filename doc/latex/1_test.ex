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
