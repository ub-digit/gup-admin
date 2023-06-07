defmodule Experiment do
  def check_env(var_name) do
    System.get_env(var_name)
    |> IO.inspect(label: "#{var_name} value")
  end
end
