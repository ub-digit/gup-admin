defmodule GupIndexManager.Resource.Persons.Merger.UserIndexLookup do
  ############################################################################################################################
  #
  #   Check if the person exist in the index, if so return the existing data
  #   This may retun multiple hits from the index
  #
  ############################################################################################################################

  def lookup(meta_data) do
    # Find matches in index by gup_admin_id, gup_person_id and identifiers
    gup_admin_id_matches = match_by_gup_admin_id(meta_data)
    gup_person_id_matches = match_by_gup_person_id(meta_data)
    identifier_matches = match_by_identifiers(meta_data)

    # Combine and deduplicate matches
    matches =
      (gup_person_id_matches ++ identifier_matches ++ gup_admin_id_matches)
      |> List.flatten()
      |> Enum.uniq()

    remapped = remap_person_data(matches)
    |> Enum.uniq()
    {:ok, meta_data, remapped}
  end

  defp match_by_gup_person_id(meta_data) do
    name = List.first(Map.get(meta_data, "names", []))
    id = Map.get(name, "gup_person_id")
    case id do
      nil ->
        []
      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_id(id) do
          {false, _} -> []
          {true, existing_records_data} -> existing_records_data
        end
    end
  end

  defp match_by_gup_admin_id(meta_data) do
    id = Map.get(meta_data, "id", nil)
    case id do
      nil ->
        []
      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_admin_id(id) do
          {false, _} -> []
          {true, existing_records_data} -> existing_records_data
        end
    end
  end

  defp match_by_identifiers(meta_data) do
     GupIndexManager.Resource.Index.Search.find_person_by_identifiers(meta_data["identifiers"]) |> elem(1)
  end

  defp remap_person_data(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
    |> Enum.filter(fn record -> Map.get(record, "deleted", false) == false end)
  end
end
