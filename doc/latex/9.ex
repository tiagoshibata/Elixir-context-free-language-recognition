def cky({rules, start}, sentence) do
  cky_table({rules, start}, sentence)
  |> Enum.at(length(sentence) - 1)
  |> Enum.at(0)
  |> MapSet.member?(start)
end
