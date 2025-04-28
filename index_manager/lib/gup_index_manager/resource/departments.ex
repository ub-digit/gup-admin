defmodule GupIndexManager.Resource.Departments do
  alias GupIndexManager.Model.Department
  alias GupIndexManager.Resource.Index


  def create(%{"id" => id} = department_data) when not is_nil(id) do
    id = Map.get(department_data, "id", nil)
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)

    attrs = %{
      "id" => id,
      "json" => department_data |> Jason.encode!()
    }

    db_department = db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)

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

  def get_gup_department_id(), do: :rand.uniform(1_000_000)


  def update(id, department_data) do
    db_department = GupIndexManager.Model.Department.find_department_by_id(id)
    attrs = %{
      "json" => department_data |> Jason.encode!(),
      "id" => id
    }

    db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
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
