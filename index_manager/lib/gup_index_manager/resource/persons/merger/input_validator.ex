defmodule GupIndexManager.Resource.Persons.Merger.InputValidator do
    ############################################################################################################################
  #
  #   Check if the person input data meets the minimum requirements
  #
  ############################################################################################################################

  def validate(person_input_data) do
    person_input_data
    |> has_gup_admin_id()
    |> is_valid_gup_name_form()
    |> has_identifiers()
    |> validate_requirements()
  end

  defp has_gup_admin_id(person_input_data) do
    id = Map.get(person_input_data, "id", nil)
    case id do
      nil -> {false, person_input_data}
      _ -> {true, person_input_data}
    end
  end
  defp is_valid_gup_name_form({_has_gup_admin_id = true, person_input_data}), do: {true, person_input_data}
  defp is_valid_gup_name_form({_has_gup_admin_id = false, person_input_data}) do
    names = Map.get(person_input_data, "names", [])
    valid = Enum.any?(names, fn name ->
      Map.has_key?(name, "first_name") && Map.has_key?(name, "last_name") &&
        Map.has_key?(name, "gup_person_id")
    end)
    {valid, person_input_data}
  end

  defp has_identifiers({_is_valid_gup_name_form = true, person_input_data}), do: {true, person_input_data}
  defp has_identifiers({_is_valid_gup_name_form = false, person_input_data}) do
    identifiers = Map.get(person_input_data, "identifiers", [])
    {length(identifiers) > 0, person_input_data}
  end

  defp validate_requirements({_has_identifiers = true, person_input_data}), do: {true, person_input_data}
  defp validate_requirements({_has_identifiers = false, person_input_data}), do: {false, person_input_data}

  def check_names(names) do
    Enum.any?(names, fn name ->
      Map.has_key?(name, "first_name") && Map.has_key?(name, "last_name") &&
        Map.has_key?(name, "gup_person_id")
    end)
  end
end
