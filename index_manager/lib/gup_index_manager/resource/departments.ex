defmodule GupIndexManager.Resource.Departments do
  alias GupIndexManager.Model.Department
  alias GupIndexManager.Resource.Index


  def create(%{"id" => id} = department_data) when not is_nil(id) do
    id = Map.get(department_data, "id", nil)
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)

    # if db_departments created_at is nil this is a new department created inside gup-admin
    # if it is not nil, its an exixting department in gup and the created_at from the json should be used
    IO.inspect("----------------------------------------- CREATE --------------------------------------------------")
    IO.inspect(db_department, label: "db_department! --------------------------------------------------------------------------------------------------")

    attrs = %{
      "id" => id,
      "is_faculty" => Map.get(department_data, "is_faculty", false),
      "parent_id" => Map.get(department_data, "parent_id", nil),
      "json" => department_data |> Jason.encode!()
    } |> set_dates(department_data, db_department)

    db_department = db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)

    IO.inspect(db_department, label: "db_department XOXOXOXOXOXOXOXOXOXOXOXOXO")
    attrs = attrs
    |> Map.put("created_at", db_department.inserted_at)
    |> Map.put("updated_at", db_department.updated_at)
    Index.update_department(attrs)

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

  defp set_dates(attrs, department_data, db_department) do
    if is_nil(db_department.inserted_at) do
      # does not exist in gup-admin, so use the dates from the json
      case Map.get(department_data, "created_at") do
        nil -> attrs
        created_at ->
          Map.put(attrs, "inserted_at", created_at)
          |> Map.put("updated_at", Map.get(department_data, "updated_at"))
      end
    else
      Map.put(attrs, "created_at", db_department.inserted_at)
      |> Map.put("updated_at", db_department.updated_at)
    end
  end

  def get_gup_department_id(), do: :rand.uniform(1_000_000)


  def update(id, department_data) do
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)
    IO.inspect("----------------------------------------- UPDATE --------------------------------------------------")
    IO.inspect(db_department, label: "db_department! --------------------------------------------------------------------------------------------------")
    attrs = %{
      "is_faculty" => Map.get(department_data, "is_faculty", false),
      "parent_id" => Map.get(department_data, "parent_id", nil),
      "json" => department_data |> Jason.encode!(),
      "id" => id
    }

    db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)

    attrs = attrs
    |> Map.put("created_at", db_department.inserted_at)
    |> Map.put("updated_at", db_department.updated_at)
    Index.update_department(attrs)

    %{
      "status" => "ok",
      "id" =>  id
    }
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
