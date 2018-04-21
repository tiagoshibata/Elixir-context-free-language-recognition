def eliminate_right_start({rules, start}) do
  if Enum.map(rules, &(Enum.member?(elem(&1, 1), start)))
  |> Enum.any? do
    {MapSet.put(rules, {"S0", [start]}), "S0"}
  else
    {rules, start}
  end
end
