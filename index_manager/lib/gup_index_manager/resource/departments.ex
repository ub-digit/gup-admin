defmodule GupIndexManager.Resource.Departments do
  alias GupIndexManager.Model.Department
  alias GupIndexManager.Resource.Index


  def create(%{"id" => id} = department_data) when not is_nil(id) do
    id = Map.get(department_data, "id", nil)
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)

    # if db_departments created_at is nil this is a new department created inside gup-admin
    # if it is not nil, its an exixting department in gup and the created_at from the json should be used

    attrs = %{
      "id" => id,
      "is_faculty" => Map.get(department_data, "is_faculty", false),
      "parent_id" => Map.get(department_data, "parent_id", nil),
      "json" => department_data |> strip_non_stored_properties() |> Jason.encode!(),
    }

    db_department = db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)
    re_index_and_report_to_gup()


    %{"status" => "ok",
      "id" => id,
    }
  end

  def create(department_data) do
    # lacking department id, get one from gup
    id = get_gup_department_id()
    department_data = Map.put(department_data, "id", id)
    create(department_data)
  end

  def strip_non_stored_properties(department_data) do
    department_data
    |> Map.delete("hierarchy")
    |> Map.delete("parent_id")
    |> Map.delete("is_faculty")
  end

  def get_gup_department_id(), do: GupIndexManager.Resource.Gup.get_next_gup_id(GupIndexManager.Resource.Gup.departments())


  def update(id, department_data) do
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)

    attrs = %{
      "id" => id,
      "is_faculty" => Map.get(department_data, "is_faculty", false),
      "parent_id" => Map.get(department_data, "parent_id", nil),
      "json" => department_data |> strip_non_stored_properties() |> Jason.encode!(),
    }

    db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)

    attrs = attrs
    |> Map.put("created_at", db_department.inserted_at)
    |> Map.put("updated_at", db_department.updated_at)
    re_index_and_report_to_gup()

    %{
      "status" => "ok",
      "id" =>  id
    }
  end

  def re_index_and_report_to_gup() do
    Index.reindex_departments()
    |> case do
      {:ok, _} -> update_gup()
      {:error, error} -> IO.inspect(error, label: "Error reindexing departments")
    end
  end

  def update_gup() do
    data = Index.Search.get_all_departments()
    GupIndexManager.Resource.Gup.update_gup(data, _initial_load = false, GupIndexManager.Resource.Gup.departments())
  end

  def remap_for_index(dep, index) do
    IO.inspect(dep, label: "dep")
    [
      %{"index" =>  %{"_index" => index, "_id" => dep["id"]}},
      dep
    ]
    |> List.flatten()
  end
end
