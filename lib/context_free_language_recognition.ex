defmodule ContextFreeLanguageRecognition do
  def is_terminal(s) do
    String.downcase(s) == s
  end

  def eliminate_start({rules, start}) do
    if Enum.map(rules, &(Enum.member?(elem(&1, 1), start)))
    |> Enum.any? do
      {MapSet.put(rules, {:S0, start}), :S0}
    else
      {rules, start}
    end
  end

  def terminal_alias_nonterminal(terminal) do
    "N_" <> String.upcase(terminal)
  end

  def terminal_alias_nonterminal_rule(terminal) do
    {terminal_alias_nonterminal(terminal), [terminal]}
  end

  def replace_solitary_terminals(rule_right) do
    Enum.map(rule_right, &(
      if is_terminal(&1) do
        terminal_alias_nonterminal(&1)
      else
        &1
      end
    ))
  end

  def eliminate_nonsolitary_terminal({rules, _}) do
    Enum.reduce(rules, MapSet.new, fn({rule_left, rule_right}, acc) ->
      right_terminals = Enum.filter(rule_right, &is_terminal(&1))
      if right_terminals == [] or length(rule_right) <= 1 do
        MapSet.put(acc, {rule_left, rule_right})
      else
        Enum.reduce(right_terminals, acc, &MapSet.put(&2, terminal_alias_nonterminal_rule &1))
        |> MapSet.put({rule_left, replace_solitary_terminals rule_right})
      end
    end)
  end
end
