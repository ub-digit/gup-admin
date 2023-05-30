defmodule GupIndexManager.Resource.Index do
  alias Elastix.Index
  alias GupIndexManager.Resource.Index.Config
  alias GupIndexManager.Model
  @index "publications"
  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL", "http://localhost:9200")
  end
  def create_index do
    Index.delete(elastic_url(), @index)
    Index.create(elastic_url(), @index, Config.config())
    |> case do
      {:ok, %{body: %{"error" => reason}}} -> {:error, reason}
      {:ok, res} -> {:ok, res}
    end
  end

  def rebuild_index do
    create_index()
    Model.Publication |> GupIndexManager.Repo.all()
    |> IO.inspect()
    |> remap_for_index()
    |> Enum.map(fn publication ->
      Elastix.Document.index(elastic_url(), @index, "_doc", publication["id"], publication, [])
    end)
  end

  def remap_for_index(publications) do
    publications
    |> Enum.map(fn publication ->
      publication.json |> Jason.decode!()
      |> Map.put("attended", publication.attended)
    end)
  end

  def update_publication(attrs) do
    json = attrs
    |> Map.get("json")
    |> Jason.decode!()
    |> Map.put("attended", attrs["attended"])
    |> Map.put("deleted", true)

    Elastix.Document.index(elastic_url(), @index, "_doc", attrs["publication_id"], json, [])
    Elastix.Index.refresh(elastic_url(), @index)
  end
end
