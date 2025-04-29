defmodule GupAdmin.Resource.Department.DepartmentValidator do
  def validate(department_data) do
    case do_validate(department_data) do
      [] -> {:ok, department_data}
      errors -> {:error, errors}
    end
  end

  defp do_validate(department_data) do
    []
    |> validate_name_en(department_data)
    |> validate_name_sv(department_data)
    |> validate_start_year(department_data)
  end

  defp validate_name_en(errors, department_data) do
    case Map.get(department_data, "name_en") do
      "" -> ["DEPARTMENT_NAME_EN_REQUIRED" | errors]
      _ -> errors
    end
  end

  defp validate_name_sv(errors, department_data) do
    case Map.get(department_data, "name_sv") do
      "" -> ["DEPARTMENT_NAME_SV_REQUIRED" | errors]
      _ -> errors
    end
  end

  defp validate_start_year(errors, department_data) do
    case Map.get(department_data, "start_year") do
      nil ->
        ["DEPARTMENT_START_YEAR_REQUIRED" | errors]
      start_year when is_integer(start_year) ->
        errors
      _ ->
        ["DEPARTMENT_START_YEAR_INVALID" | errors]
    end
  end
end
