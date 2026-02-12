defmodule GupIndexManager.Resource.Persons.Merger.Actions do
  alias GupIndexManager.Resource.Persons.Merger.NameForms
  def generate_actions({:error, reason, {meta_data, existing_data}}), do: {:error, reason, {meta_data, existing_data}}
  def generate_actions({:ok, meta_data}) do
    # only actions are to check if person has a gup_perosn_id and if not aquire one, and then create user in db and index.
  end
  def generate_actions({false, meta_data, existing_data}) do
    # bulk of merge logic goes here.
    # Pick one of the exixting records as primary_record and add all data from the other record(s)
    # to the primary record, check if a new gup_person_id needs to be aquired in meta_data. check if meta_data name_forms already exists in existing data.
    # if a merge has occured between any two records, set the all but primary to "deleted".
    {primary_record, secondary_records} = List.pop_at(existing_data, 0)

    # first merge all the secondary records into the primary record.
    actions = generate_existing_records_actions(primary_record, secondary_records)
    # maybe combine names, identifiers fom primary  and secondary data to  compare with meta_data

  end

  def generate_existing_records_actions(_primary_record, _secondary_records = []), do: []
  def generate_existing_records_actions(primary_record, secondary_records) do
    gen_name_actions(primary_record, secondary_records)
  end

  defp gen_name_actions(primary_record, secondary_records) do
    secondary_names = secondary_records |> Enum.flat_map(& &1["names"])
    primary_names = primary_record["names"]
    # For each name in the secondary records, check if it already exists in the primary record, if not add an action to add it.
    Enum.flat_map(secondary_names, fn secondary_name ->
      if Enum.any?(primary_names, fn primary_name -> NameForms.is_same_name_form?(primary_name, secondary_name) end) do
        []
      else
        [%{action: "add_name", name: secondary_name}]
      end
    end)
  end
end
