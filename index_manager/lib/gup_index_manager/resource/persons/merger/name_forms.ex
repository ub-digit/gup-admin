defmodule GupIndexManager.Resource.Persons.Merger.NameForms do
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  require Logger

  # This is a new person with no prior records in the index, we can safely set the primary name to the first name form in the input data
  def set_primary_name({meta_data, possible_candidates = []}) when length(possible_candidates) < 1 do
    # No existing record, set primary name to the first name form in input data
    meta_data = Map.put(meta_data, "primary_name", get_primary_name_from_record(meta_data))
    {:ok, meta_data, []}
  end

  # Force incoming name to be primary.
  def set_primary_name({%{"force_primary_name" => true} = meta_data, possible_candidates}) do
    meta_data = Map.put(meta_data, "primary_name", get_primary_name_from_record(meta_data))
    {:ok, meta_data, possible_candidates}
  end

  # Figure out the primary name based on identifiers
  def set_primary_name({%{"force_primary_name" => false} = meta_data, possible_candidates})
      when length(possible_candidates) > 0 do
    # Check if any of the existing records have a POP_ID identifier, if so use the primary name from that record
    primary_name_record =
      Enum.find(possible_candidates, fn record ->
        Identifiers.has_identifier?(record, Identifiers._POP_ID_CODE())
      end) ||
        Enum.find(possible_candidates, fn record ->
          Identifiers.has_identifier?(record, Identifiers._X_ACCOUNT_CODE())
        end) ||
        meta_data

    meta_data =
      Map.put(meta_data, "primary_name", get_primary_name_from_record(primary_name_record))

    {:ok, meta_data, possible_candidates}
  end

  defp get_primary_name_from_record(record) do
    Enum.find(record["names"], fn name -> Map.get(name, "primary", false) == true end) ||
      List.first(record["names"])
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

    # If this returns true the are considered the same name form.
    names_match? && ids_match?
  end

  def has_gup_person_id?(name_form) do
    Map.has_key?(name_form, "gup_person_id") && name_form["gup_person_id"] != nil
  end

  def has_existing_gup_peron_id?(name_form, existing_name_forms) do
    Enum.any?(existing_name_forms, fn existing_name_form ->
      Map.has_key?(existing_name_form, "gup_person_id") &&
        existing_name_form["gup_person_id"] == name_form["gup_person_id"]
    end)
  end


end
