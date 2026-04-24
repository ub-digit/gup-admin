defmodule GupIndexManager.Resource.Persons.Merger.NameForms do
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  require Logger

  # This is a new person with no prior records in the index, we can safely set the primary name to the first name form in the input data
  def set_primary_name({meta_data, matches = []}) when length(matches) < 1 do
    # No existing record, set primary name to the first name form in input data
    meta_data = Map.put(meta_data, "primary_name", get_primary_name_from_record(meta_data))
    {:ok, meta_data, []}
  end

  # Force incoming name to be primary.
  def set_primary_name({%{"force_primary_name" => true} = meta_data, matches}) do
    matches_names = Enum.flat_map(matches, fn record -> record["names"] || [] end)
    new_primary_name = get_primary_name_from_record(meta_data)
    # Check if the new primary name already exists in the existing records, if so we can just set that name form to primary.
    existing_primary_name_form = Enum.find(matches_names, fn name_form ->
      is_same_name_form?(name_form, new_primary_name)
    end)
    meta_data = if existing_primary_name_form do
      # We can just set the existing name form to primary, and skip the acquire_gup_person_id action if the existing name form already has a gup_person_id.
      Map.put(meta_data, "primary_name", existing_primary_name_form)
    else
      # We need to acquire a gup_person_id for the new primary name form, and then set it to primary.
      Map.put(meta_data, "primary_name", new_primary_name)
    end
    # meta_data = Map.put(meta_data, "primary_name", get_primary_name_from_record(meta_data))
    {:ok, meta_data, matches}
  end

  # Figure out the primary name based on identifiers
  def set_primary_name({%{"force_primary_name" => false} = meta_data, matches}) when length(matches) > 0 do
    # Check if any of the existing records have a POP_ID identifier, if so use the primary name from that record
    primary_name_record =
      Enum.find(matches, fn record ->
        Identifiers.has_identifier?(record, Identifiers._POP_ID_CODE())
      end) ||
        Enum.find(matches, fn record ->
          Identifiers.has_identifier?(record, Identifiers._X_ACCOUNT_CODE())
        end) ||
        meta_data

    meta_data =
      Map.put(meta_data, "primary_name", get_primary_name_from_record(primary_name_record))

      # extra check to see if its just a primary name change in a single post
      meta_data = case length(matches) do
        1 -> # could be same record
          case meta_data["id"] == matches |> List.first() |> Map.get("id") do
            true -> Map.put(meta_data, "primary_name", get_primary_name_from_record(meta_data))
            false -> meta_data
          end

        _ -> meta_data
      end
    {:ok, meta_data, matches}
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
      case {not is_nil(Map.get(name_form1, "gup_person_id", nil)), not is_nil(Map.get(name_form2, "gup_person_id", nil))} do
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

  def has_existing_gup_person_id?(name_form, existing_name_forms) do
    Enum.any?(existing_name_forms, fn existing_name_form ->
      Map.has_key?(existing_name_form, "gup_person_id") &&
        existing_name_form["gup_person_id"] == name_form["gup_person_id"]
    end)
  end

  def is_non_existing_name_form?(name_form, existing_name_forms) do
    Enum.any?(existing_name_forms, fn existing_name_form ->
      is_same_name_form?(name_form, existing_name_form) |> IO.inspect(label: "Comparing with existing name form")
    end)
  end

  def is_primary_name_form?(primary_name_form, data) do
    name_forms = Enum.flat_map(data, fn p -> p["names"] end)
    Enum.any?(name_forms, fn name_form ->
      is_same_name_form?(primary_name_form, name_form) && Map.get(name_form, "primary", false) == true
    end)
  end

  def aggregate_new_names(other_names, primary_record_names) do
    other_names
    |> Enum.filter(fn name -> not Enum.any?(primary_record_names, fn existing_name ->
        is_same_name_form?(name, existing_name)
      end)
    end)
  end


end
