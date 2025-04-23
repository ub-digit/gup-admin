defmodule GupAdmin.Resource.Department.DepartmentValidator do
  def validate(department_data) do
    # Validate the department data
    # errors = []

    # # Check if the department name is present
    # if Map.get(department_data, "name") == nil do
    #   errors = ["Department name is required" | errors]
    # end

    # # Check if the department code is present
    # if Map.get(department_data, "code") == nil do
    #   errors = ["Department code is required" | errors]
    # end

    # # Check if the department type is present
    # if Map.get(department_data, "type") == nil do
    #   errors = ["Department type is required" | errors]
    # end

    # # Return the validation result
    # if Enum.empty?(errors) do
    #   {:ok, department_data}
    # else
    #   {:error, %{errors: %{validation: errors}}}
    # end
    {:ok, department_data}
  end
end
