defmodule GupIndexManager.Resource.Departments do
  alias GupIndexManager.Model.Department
  alias GupIndexManager.Resource.Index

  # def elastic_url do
  #   System.get_env("ELASTICSEARCH_URL", "http://localhost:9200")
  # end



  # def initialize do
  #   {:ok, departments} = File.read("../data/departments/departments.json")
  #   data = departments
  #   |> Jason.decode()
  #   |> elem(1)
  #   |> Map.get("departments")
  #   |> Enum.map(fn dep -> remap_for_index(dep, "departments") end)
  #   |> List.flatten()

  #   Elastix.Index.delete(elastic_url(), "departments")
  #   Elastix.Index.create(elastic_url(), "departments", GupIndexManager.Resource.Index.Config.departments_config())
  #   # Elastix.Index.create(elastic_url(), "departments", %{})
  #   Elastix.Bulk.post(elastic_url(), data)
  # end

  def create(department_data) do
    department_id = Map.get(department_data, "id")
    db_department = GupIndexManager.Model.Department.find_department_by_department_id(department_id)
    IO.inspect(db_department, label: "db_department")
    attrs = %{
      "json" => department_data |> Jason.encode!(),
      "department_id" => department_id
    }

    db_department
    |> Department.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    Index.update_department(attrs)

    %{"status_generate_department" => "200", "message" => "Department created"}
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
