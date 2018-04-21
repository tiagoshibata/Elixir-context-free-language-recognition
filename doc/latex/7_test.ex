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
