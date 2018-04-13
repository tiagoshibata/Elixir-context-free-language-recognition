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

  def build_nonsolitary_terminal_rule(terminal) do
    {}
  end

  def terminal_alias_nonterminal(terminal) do
    {"N_" <> String.upcase(terminal), terminal}
  end

  def eliminate_nonsolitary_terminal({rules, start}) do
    Enum.reduce(rules, MapSet.new, fn({rule_left, rule_right}, acc) ->
      right_terminals = Enum.filter(rule_right, &is_terminal(&1))
      if right_terminals == [] or length(rule_right) <= 1 do
        MapSet.put(acc, {rule_left, rule_right})
      else
        MapSet.put(acc, )
      end
    end)
  end
end
