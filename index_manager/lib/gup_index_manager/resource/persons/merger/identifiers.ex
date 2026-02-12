defmodule GupIndexManager.Resource.Persons.Merger.Identifiers do

  require Logger
  # Constants for identifier codes
  @orcid_code "ORCID"
  @pop_id_code "POP"
  @x_account_code "X_ACCOUNT"

  def has_any_of_these_identifiers?(person, identifiers_to_look_for) do
    Enum.any?(identifiers_to_look_for, fn identifier -> Enum.any?(person["identifiers"], fn person_identifier -> person_identifier["code"] == identifier end )end)
  end

  def has_identifier?(person, identifier_to_look_for) do
    Enum.any?(person["identifiers"], fn person_identifier -> person_identifier["code"] == identifier_to_look_for end)
  end

  def colliding_identifiers({_exists_in_index = false, person_input_data, []}), do:  {:ok, person_input_data}
  def colliding_identifiers({_exists_in_index = true, meta_data, existing_data}) do
    # Check within existing records have different "value" for the same "code" in identifiers. Do NOT include person at this stage.
    identifiers_to_check = [@orcid_code, @x_account_code]
    [existing_data | [meta_data]]
    |> List.flatten()
    |> Enum.flat_map(fn record -> Enum.filter(record["identifiers"], fn identifier -> identifier["code"] in identifiers_to_check end) end)
    |> IO.inspect(label: "List of identifiers")
    |> Enum.group_by(& &1["code"])
    |> Enum.any?(fn {_code, maps} ->
      values = Enum.map(maps, & &1["value"])
      length(Enum.uniq(values)) > 1
    end)
    |> case do
      true -> {:error, "Colliding ORCID and/or X_ACCOUNT", {meta_data, existing_data}}
      false -> {false, meta_data, existing_data}
    end
  end

  def _ORCID_CODE, do: @orcid_code
  def _POP_ID_CODE, do: @pop_id_code
  def _X_ACCOUNT_CODE, do: @x_account_code

end
