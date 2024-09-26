defmodule GupIndexManager.Resource.Persons.Merger3 do
  def merge(person_input_data) do
    IO.puts("MERGE PERSON!!!!!")
    with {true, person_input_data} <- meets_minimum_person_requirements(person_input_data) do
      person_input_data
      |> parse_input_data()
      # |> has_gup_admin_id()
      # |> exists_in_index()
      # |> colliding_identifiers()
      # |> input_data_has_gup_person_id()
      # |> has_matching_gup_person_id()
      # |> set_primary_and_secondary_data()
      # |> merge_person()
      # |> create_or_update_person()
    else
      {false, error_message} -> {:error, error_message}
    end
  end

  defp meets_minimum_person_requirements(person_input_data) do
    IO.puts("MEETS MINIMUM PERSON REQUIREMENTS CHECK")
    case person_input_data do
      %{"identifiers" => [%{"code" => "X_ACCOUNT"}]} ->
        {true, person_input_data}

      %{"identifiers" => [%{"code" => "SCOPUS"}]} ->
        {true, person_input_data}


      %{"identifiers" => [%{"code" => "ORCID"}]} ->
        {true, person_input_data}
      # has a valid name form with gup_person_id
      %{"names" => names} ->
        {check_names(names), person_input_data}

      # gup admin internal id
      %{"id" => _} ->
        {true, person_input_data}

      _ ->
        {false, "The person_input_data does not meet the minimum requirements"}
    end
  end

  def check_names(names) do
    Enum.any?(names, fn name -> Map.has_key?(name, "first_name") && Map.has_key?(name, "last_name") && Map.has_key?(name, "gup_person_id") end)
  end

  def parse_input_data(person_input_data) do
    IO.puts("PARSE INPUT DATA")


    %{
      "gup_person_id" => get_gup_person_id(person_input_data),
      "gup_admin_id" =>  get_gup_admin_id(person_input_data),
      "input_data" => person_input_data,
      # "names" => get_names(person_input_data),
      # "exists_in_index" => exists_in_index,
      # "colliding_identifiers" => false,
      # "existing_data" => existing_data
    }
    |> IO.inspect(label: "Parsed input data")
  end

  defp get_gup_person_id(person_input_data) do
    IO.puts("GET GUP PERSON ID")
    person_input_data
    |> Map.get("names", [])
    |> List.first()
    |> case do
      nil -> nil
      name -> Map.get(name, "gup_person_id")
    end
  end

  defp get_gup_admin_id(person_input_data) do
    IO.puts("GET GUP ADMIN ID")
    Map.get(person_input_data, "id", nil)
  end

  defp get_identifiers(person_input_data) do
    IO.puts("GET IDENTIFIERS")
    person_input_data
    |> Map.get("identifiers", [])
  end

end
