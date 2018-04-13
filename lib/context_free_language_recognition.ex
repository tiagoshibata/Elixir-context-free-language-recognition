defmodule ContextFreeLanguageRecognition do
  def atoms_to_string(atoms) do
    Enum.map(atoms, &Atom.to_string(&1))
    |> Enum.join()
  end

  def is_terminal(atom) do
    string = Atom.to_string(atom)
    not (String.downcase(string) != string)
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

  def eliminate_nonsolitary_terminal({rules, start}) do
    Enum.reduce(rules, MapSet.new, fn({rule_left, rule_right}, acc) ->
      right_terminals = Enum.filter(rule_right, &is_terminal(&1))

      MapSet.put(acc, )
    )
    if Enum.map(rules, &(Enum.member?(elem(&1, 1), start)))
    |> Enum.any? do
      {[{:S0, start} | rules], :S0}
    else
      {rules, start}
    end
  end
end
