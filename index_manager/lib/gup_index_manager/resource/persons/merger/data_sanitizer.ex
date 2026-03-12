defmodule GupIndexManager.Resource.Persons.Merger.DataSanitizer do
  ############################################################################################################################
  #
  #   Sanitize incomming data
  #
  ############################################################################################################################

  def sanitize_data(data) do
    {:ok,
      %{
        "id" => Map.get(data, "id", nil),
        "names" => sanitize_names(Map.get(data, "names", [])),
        "departments" => Map.get(data, "departments", []),
        "identifiers" => Map.get(data, "identifiers", []) |> trim_identifier_values(),
        "year_of_birth" => get_year_of_birth(Map.get(data, "year_of_birth", nil)),
        "email" => Map.get(data, "email", nil),
        "deleted" => Map.get(data, "deleted", false),
        "is_merged" => Map.get(data, "is_merged", false),
        "force_primary_name" => Map.get(data, "force_primary_name", false)
      }
    }
  end

  def trim_identifier_values(identifiers) do
    Enum.map(identifiers, fn identifier ->
      case Map.get(identifier, "value", nil) do
        nil -> identifier
        value -> Map.put(identifier, "value", String.trim(value))
      end
    end)
  end

  defp get_year_of_birth(y_o_b) when is_bitstring(y_o_b), do: String.to_integer(y_o_b)
  defp get_year_of_birth(y_o_b) when is_integer(y_o_b), do: y_o_b
  defp get_year_of_birth(_), do: nil

  defp sanitize_names(names) do
      names
     |> Enum.map(fn name ->
      %{
        "first_name" => Map.get(name, "first_name", ""),
        "last_name" => Map.get(name, "last_name", ""),
        "full_name" => "#{Map.get(name, "first_name", "")} #{Map.get(name, "last_name", "")}",
        "start_date" => Map.get(name, "start_date", nil),
        "end_date" => Map.get(name, "end_date", nil),
        "gup_person_id" => Map.get(name, "gup_person_id", nil),
        "primary" => Map.get(name, "primary", false)
      }
      end)
  end
end
