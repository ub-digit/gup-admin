defmodule GupIndexManager.Resource.Persons.Merger do
  def merge(person_input_data) when is_map(person_input_data) do
    person_input_data
    |> meets_the_minimum_person_requirements()
    |> merge_person()
  end

  defp meets_the_minimum_person_requirements(person_input_data) do
    IO.inspect("MEETS MINIMUM REQUIREMENTS")
    case person_input_data do
      %{x_account: _} -> {:ok, person_input_data}
      %{first_name: _, last_name: _, id: _} -> {:ok, person_input_data}
      %{admin_id: _} -> {:ok, person_input_data}
      _ -> {:error, "The person_input_data does not meet the minimum requirements"}
    end
  end

  defp merge_person({:ok, person_input_data}) do
    # This is where the actual merging of the person data would happen
    # For now, we'll just return the person_input_data
    {:ok, [{:create_person, person_input_data}]}
  end

  defp merge_person({:error, error_message}) do
    {:error, error_message}
  end

end
