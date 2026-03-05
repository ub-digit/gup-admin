defmodule GupIndexManager.Resource.Persons.Merger.Actions do
  alias Postgrex.Extensions.Name
  alias GupIndexManager.Resource.Persons.Merger.NameForms

  def generate_actions({:error, reason, {meta_data, possible_candidates}}), do: {:error, reason, {meta_data, possible_candidates}}
  def generate_actions({meta_data, _possible_candidates = []}) do
      # No existing data, so this is a new person, we need to create a new record in the index and db.
      # Check if meta_data has a gup_person_id, if not aquire one.
      # Create user in db and index.

      names_without_gup_person_id = meta_data["names"] || [] |> Enum.filter(fn name -> !NameForms.has_gup_person_id?(name) end)
      actions =
      Enum.reduce(names_without_gup_person_id, [], fn name, actions ->
        #add this to actions {:aquire_gup_person_id, gup_person_id} for every name without gup_person_id

        actions ++ [{:acquire_gup_person_id, name}]
      end)
      |> mandatory_actions(meta_data, [])
      data = Map.delete(meta_data, "primary_name")
      {:ok, data, actions}
  end

  def generate_actions({meta_data, possible_candidates}) do

    # bulk of merge logic goes here.
    # Pick one of the exixting records as primary_record and add all data from the other record(s)
    # to the primary record, check if a new gup_person_id needs to be aquired in meta_data. check if meta_data name_forms already exists in existing data.
    # if a merge has occured between any two records, set the all but primary to "deleted".
    {primary_record, secondary_records} = List.pop_at(possible_candidates, 0)
    actions = []
    |> name_actions(primary_record, secondary_records ++ [meta_data])
    |> identifier_actions(primary_record, secondary_records ++ [meta_data])
    |> deparment_actions(primary_record, secondary_records ++ [meta_data])
    |> delete_merged_records(secondary_records)
    |> mandatory_actions(meta_data, [primary_record | secondary_records])

     {:ok, primary_record, actions}
  end

  defp name_actions(actions, primary_record, other_records) do
    primary_record_names = primary_record["names"] || []
    other_names = Enum.flat_map(other_records, fn record -> record["names"] || [] end)
    # check for names that doesnt exist in primary record, but exists in other records, and add action to add this name to primary record.
    new_names = NameForms.aggregate_new_names(other_names, primary_record_names)
    actions ++ Enum.map(new_names, fn name ->
      case NameForms.has_existing_gup_person_id?(name, primary_record_names) do
        true -> {:update_name, name}
        false ->
          Enum.any?(primary_record_names, fn existing_name -> NameForms.is_same_name_form?(name, existing_name) end)
          |> case do
            true -> [] # maybe update exixting name if new start_date or end_date is present.
            false ->
              case NameForms.has_gup_person_id?(name) do
                true -> {:add_name, name}
                false -> {:acquire_gup_person_id, name} # aquire_goup_person_id action will trigger :add_name action after a gup_person_id has been aquired and added to the name form.
              end
          end
      end
    end)
    |> List.flatten()
  end

  defp identifier_actions(actions, primary_record, other_records) do
    primary_record_identifiers = primary_record["identifiers"] || [] |> Enum.uniq()
    other_identifiers = Enum.flat_map(other_records, fn record -> record["identifiers"] || [] end)
    # check for identifiers that doesnt exist in primary record, but exists in other records, and add action to add this identifier to primary record.
    new_identifiers = Enum.filter(other_identifiers, fn identifier -> identifier not in primary_record_identifiers end) |> Enum.uniq()

    actions ++ Enum.map(new_identifiers, fn identifier ->
      {:add_identifier, identifier}
    end)
  end

  defp deparment_actions(actions, primary_record, other_records) do
    primary_record_departments = primary_record["departments"] || []
    other_departments = Enum.flat_map(other_records, fn record -> record["departments"] || [] end)
      # check if any department in other_deps does not exists in prim_deps by comparing name TODO: ORGDB_ID is not present, shouldnt it be?
      new_deps = Enum.filter(other_departments, fn other_dep ->
        not Enum.any?(primary_record_departments, fn prim_dep ->
          # prim_dep["orgdb_id"] == other_dep["orgdb_id"] &&
          prim_dep["name"] == other_dep["name"]
        end)
      end)

      #now check if any department in other_deps has the same orgdb_id and name as a department in prim_deps but a different start_date.
      new_deps ++ Enum.filter(other_departments, fn other_dep ->
        Enum.any?(primary_record_departments, fn prim_dep ->
          # prim_dep["orgdb_id"] == other_dep["orgdb_id"] &&
          prim_dep["name"] == other_dep["name"] && prim_dep["start_date"] != other_dep["start_date"]
        end)
      end)
      |> List.flatten()
      |> Enum.uniq()

      deps_to_update = Enum.filter(other_departments, fn other_dep ->
        Enum.any?(primary_record_departments, fn prim_dep ->
          # prim_dep["orgdb_id"] == other_dep["orgdb_id"] &&
          prim_dep["name"] == other_dep["name"] && prim_dep["end_date"] != other_dep["end_date"] && prim_dep["start_date"] == other_dep["start_date"]
        end)
      end)
      actions ++ Enum.map(new_deps, fn department ->
        {:add_department, department}
      end) ++ Enum.map(deps_to_update, fn department ->
        {:update_department, department}
      end)
  end

  defp delete_merged_records(actions, secondary_records) do
    actions ++ Enum.map(secondary_records, fn record ->
      {:delete_person, record["id"]}
    end)
  end

  defp mandatory_actions(actions, meta_data, _combined_data) do
    # if primary name is the same in existing data as in meta_data, skip that action
    IO.inspect("Mandatory actions check ---<")
    actions ++ [{:set_primary_name, meta_data["primary_name"]}, {:create_or_update_person}] |> List.flatten()    # |> Kernel.++(
    #   case Enum.any?(actions, fn action -> elem) do
    #   true -> []
    #   false -> [{:set_primary_name, meta_data["primary_name"]}]
    # end)
    # |> Kernel.++([{:create_or_update_person}])

  end


  def get_utc_date_now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
    |> String.trim_trailing("Z")
  end
end
