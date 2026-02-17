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

  def colliding_identifiers({meta_data, possible_candidates = []}), do:  {:ok, meta_data, possible_candidates}
  def colliding_identifiers({meta_data, possible_candidates}) when length(possible_candidates) > 0 do
    identifiers_to_look_for = [@orcid_code, @x_account_code, @pop_id_code] # should POP_ID be included?
    [possible_candidates | [meta_data]]
    |> List.flatten()
    |> Enum.flat_map(fn record -> Enum.filter(record["identifiers"], fn identifier -> identifier["code"] in identifiers_to_look_for end) end)
    |> Enum.group_by(& &1["code"])
    |> Enum.any?(fn {_code, maps} ->
      values = Enum.map(maps, & &1["value"])
      length(Enum.uniq(values)) > 1
    end)
    |> case do
      true -> {:error, "Colliding ORCID and/or X_ACCOUNT and/or POP_ID", {meta_data, possible_candidates}}
      false -> {:ok, meta_data, possible_candidates}
    end
  end

  def _ORCID_CODE, do: @orcid_code
  def _POP_ID_CODE, do: @pop_id_code
  def _X_ACCOUNT_CODE, do: @x_account_code
end
