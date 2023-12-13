defmodule GupIndexManager.Resource.Departments do
  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL", "http://localhost:9200")
  end

  def initialize do
    {:ok, departments} = File.read("../data/departments/departments.json")
    data = departments
    |> Jason.decode()
    |> elem(1)
    |> Map.get("departments")
    |> Enum.map(fn dep -> remap_for_index(dep, "departments") end)
    |> List.flatten()

    Elastix.Index.delete(elastic_url(), "departments")
    Elastix.Index.create(elastic_url(), "departments", GupIndexManager.Resource.Index.Config.departments_config())
    Elastix.Bulk.post(elastic_url(), data)
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
