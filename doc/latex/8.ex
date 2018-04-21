def cky_table({rules, start}, sentence) do
  m = init_cky({rules, start}, sentence)
  n = length(sentence)
  nt_rules = Enum.filter(rules, &(length(elem(&1, 1)) == 2))
  Enum.reduce(2..n, m, fn(l, acc_l) ->
    Enum.reduce(0..(n - l), acc_l, fn(s, acc_s) ->
      Enum.reduce(0..l - 2, acc_s, fn(p, acc_p) ->
        Enum.reduce(nt_rules, acc_p, fn({a, [b, c]}, acc) ->
          if MapSet.member?(Enum.at(acc, p) |> Enum.at(s), b) and MapSet.member?(Enum.at(acc, l - p - 2) |> Enum.at(s + p + 1), c) do
            List.update_at(acc, l, fn(sublist) -> List.update_at(sublist, s, &MapSet.put(&1, a)) end)
          else
            acc
          end
        end)
      end)
    end)
  end)
end
