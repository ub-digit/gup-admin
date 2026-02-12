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
end
