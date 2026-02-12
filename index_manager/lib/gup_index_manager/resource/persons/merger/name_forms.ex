defmodule GupIndexManager.Resource.Persons.Merger.NameForms do
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  require Logger


  # This is a new person with no prior records in the index, we can safely set the primary name to the first name form in the input data
  def set_primary_name({_exists_in_index = false, meta_data, _existing_data}) do
    # No existing record, set primary name to the first name form in input data
    meta_data = Map.put(meta_data, "primary_name",  get_primary_name_from_record(meta_data))
    {false, meta_data, []}
  end

  # Force incoming name to be primary.
  def set_primary_name({_exists_in_index = true, %{"force_primary_name" => true} = meta_data, existing_data}) do
    meta_data = Map.put(meta_data, "primary_name",  get_primary_name_from_record(meta_data))
    {true, meta_data, existing_data}
  end

  # Figure out the primary name based on identifiers
  def set_primary_name({exists_in_index = true, %{"force_primary_name" => false} = meta_data, existing_data}) do
    # Check if any of the existing records have a POP_ID identifier, if so use the primary name from that record
    primary_name_record = Enum.find(existing_data, fn record -> Identifiers.has_identifier?(record, Identifiers._POP_ID_CODE()) end) ||
                          Enum.find(existing_data, fn record -> Identifiers.has_identifier?(record, Identifiers._X_ACCOUNT_CODE()) end) ||
                          meta_data

    meta_data = Map.put(meta_data, "primary_name", get_primary_name_from_record(primary_name_record))
    {exists_in_index, meta_data, existing_data}
  end

  defp get_primary_name_from_record(record) do
    Enum.find(record["names"], fn name -> Map.get(name, "primary", false) == true end) || List.first(record["names"])
  end

  def is_same_name_form?(name_form1, name_form2) do
  # First & last name must match in all cases
  names_match? =
    name_form1["first_name"] == name_form2["first_name"] &&
    name_form1["last_name"] == name_form2["last_name"]

  # Now check IDs only if both forms actually have them
  ids_match? =
    case {Map.has_key?(name_form1, "gup_person_id"), Map.has_key?(name_form2, "gup_person_id")} do
      {true, true} ->
        name_form1["gup_person_id"] == name_form2["gup_person_id"]

      # If only one has id → we don't consider it a mismatch (usually)
      {_, _} ->
        true
    end

  names_match? && ids_match? # If this returns true the are considered the same name form.
end
end
