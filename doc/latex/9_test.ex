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
