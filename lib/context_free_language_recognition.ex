defmodule ContextFreeLanguageRecognition do
  def is_terminal(s) do
    String.downcase(s) == s
  end

  def eliminate_right_start({rules, start}) do
    if Enum.map(rules, &(Enum.member?(elem(&1, 1), start)))
    |> Enum.any? do
      {MapSet.put(rules, {"S0", [start]}), "S0"}
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

  def eliminate_nonsolitary_terminal(rules) do
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

  def subsymbol(symbol, depth) do
    if depth == 0 do
      symbol
    else
      "#{symbol}_#{depth}"
    end
  end

  def eliminate_right_side_with_multiple_nonterminals({rule_left, rule_right}, depth) do
    if length(rule_right) > 2 do
      [head | tail] = rule_right
      new_rule = {subsymbol(rule_left, depth), [head, subsymbol(rule_left, depth + 1)]}
      MapSet.put eliminate_right_side_with_multiple_nonterminals({rule_left, tail}, depth + 1), new_rule
    else
      MapSet.new [{subsymbol(rule_left, depth), rule_right}]
    end
  end

  def eliminate_right_side_with_multiple_nonterminals(rules) do
    Enum.reduce(rules, MapSet.new, fn(rule, acc) ->
      MapSet.union(acc, eliminate_right_side_with_multiple_nonterminals(rule, 0))
    end)
  end

  def split_first(list, divider) do
    {left, right} = Enum.split_while(list, divider)
    if right == [] do
      {list, nil}
    else
      [_ | right] = right
      {left, right}
    end
  end

  def rewrite_empty_symbol(rule_right, empty_symbol) do
    {left, right} = split_first(rule_right, &(&1 != empty_symbol))
    if right == nil do
      [rule_right]
    else
      Enum.flat_map(rewrite_empty_symbol(right, empty_symbol), &(
        [left ++ &1, left ++ [empty_symbol | &1]]
      ))
    end |> MapSet.new
  end

  def eliminate_empty_rules(rules) do
    empty_rule = Enum.find(rules, &(elem(&1, 1) == []))
    if is_nil(empty_rule) do
      rules
    else
      MapSet.delete(rules, empty_rule)
      |> Enum.flat_map(fn({rule_left, rule_right}) ->
        Enum.map(rewrite_empty_symbol(rule_right, elem(empty_rule, 0)), &({rule_left, &1}))
      end)
      |> MapSet.new
      |> eliminate_empty_rules
    end
  end

  def eliminate_unit_rules(rules) do
    unit_rule = Enum.find(rules, fn({_, rule_right}) ->
      length(rule_right) == 1 and not is_terminal(hd(rule_right))
    end)
    if is_nil(unit_rule) do
      rules
    else
      {unit_left, [unit_right]} = unit_rule
      Enum.filter(rules, &(elem(&1, 0) == unit_right))
      |> Enum.map(fn({^unit_right, rule_right}) -> {unit_left, rule_right} end)
      |> MapSet.new
      |> MapSet.union(rules)
      |> MapSet.delete(unit_rule)
      |> eliminate_unit_rules
    end
  end

  def to_chomsky_nf({rules, start}) do
    {rules, start} = eliminate_right_start({rules, start})
    rules = eliminate_nonsolitary_terminal(rules)
    |> eliminate_right_side_with_multiple_nonterminals
    |> eliminate_empty_rules
    |> eliminate_unit_rules
    {rules, start}
  end
end
