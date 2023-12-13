defmodule GupIndexManager.Resource.Departments do
  def initialize do
    {:ok, departments} = File.read("../data/departments/departments.json")
    data = departments
    |> Jason.decode()
    |> elem(1)
    |> Map.get("departments")
    |> Enum.map(fn dep -> remap_for_index(dep, "departments") end)
    |> List.flatten()

    Elastix.Index.delete("http://localhost:9200", "departments")
    Elastix.Index.create("http://localhost:9200", "departments", GupIndexManager.Resource.Index.Config.departments_config())
    Elastix.Bulk.post("http://localhost:9200", data)
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
