defmodule GupIndexManager.Resource.Persons.Merger.UserIndexLookup do
  ############################################################################################################################
  #
  #   Check if the person exist in the index, if so return the existing data
  #   This may retun multiple hits from the index
  #
  ############################################################################################################################

  def lookup(person_input_data) do
    # Find matches in index by gup_admin_id, gup_person_id and identifiers
    gup_admin_id_matches = match_by_gup_admin_id(person_input_data)
    gup_person_id_matches = match_by_gup_person_id(person_input_data)
    identifier_matches = match_by_identifiers(person_input_data)

    # Combine and deduplicate matches
    matches =
      (gup_person_id_matches ++ identifier_matches ++ gup_admin_id_matches)
      |> List.flatten()
      |> Enum.uniq()

    remapped = remap_person_data(matches)
    |> Enum.uniq()
    {length(remapped) > 0, person_input_data, remapped}
  end

  defp match_by_gup_person_id(person_input_data) do
    name = List.first(Map.get(person_input_data, "names", []))
    id = Map.get(name, "gup_person_id")
    case id do
      nil ->
        []

      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_id(id) do
          {false, _} -> []
          {true, existing_person_data} -> existing_person_data
        end
    end
  end

  defp match_by_gup_admin_id(person_input_data) do
    id = Map.get(person_input_data, "id", nil)
    case id do
      nil ->
        []
      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_admin_id(id) do
          {false, _} -> []
          {true, existing_person_data} -> existing_person_data
        end
    end
  end

  defp match_by_identifiers(person_input_data) do
     GupIndexManager.Resource.Index.Search.find_person_by_identifiers(person_input_data["identifiers"]) |> elem(1)
  end

  defp remap_person_data(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
    |> Enum.filter(fn person -> Map.get(person, "deleted", false) == false end)
  end

end
