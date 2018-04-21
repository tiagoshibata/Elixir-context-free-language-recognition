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
