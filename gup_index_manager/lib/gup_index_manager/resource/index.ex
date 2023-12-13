defmodule GupIndexManager.Resource.Index do
  alias Elastix.Index
  alias GupIndexManager.Resource.Index.Config
  alias GupIndexManager.Model
  @index "publications"
  @departments "departments"
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
    case Elastix.Index.exists?(elastic_url(), @index) do
      {:ok, true} -> :ok
      {:ok, false} -> create_index()
    end
    json = attrs
    |> Map.get("json")
    |> Jason.decode!()
    |> Map.put("attended", attrs["attended"])
    |> Map.put("deleted", attrs["deleted"])

    Elastix.Document.index(elastic_url(), @index, "_doc", attrs["publication_id"], json, [])
    |> case do
      {:ok, %{body: %{ "error" => error}}} -> {:error, error}
      {:ok, _} -> {:ok, "ok"}
    end
    |> case do
      {:error, error} -> %{"error" => error}
      {:ok, _} ->
        Elastix.Index.refresh(elastic_url(), @index)
        |> case do
          {:ok, %{body: %{ "error" => error}}} -> {:error, error}
          {:ok, _} -> %{"status" => "ok"}
        end
    end
  end

  def mark_as_pending(id) do
    #TODO: needs error handling
    {:ok, %{body: body}} = Elastix.Document.get(elastic_url(), @index, "_doc", id)
    body = body
    |> Map.get("_source")
    |> Map.put("pending", true)
    res = Elastix.Document.index(elastic_url(), @index, "_doc", id, body, [])
    Elastix.Index.refresh(elastic_url(), @index)
    res
  end

  def get_publication(id) do
    Elastix.Document.get(elastic_url(), @index, "_doc", id)
    |> case do
      {:ok, %{status_code: 404}} -> {:error, "Not found"}
      {:ok, %{body: body}} -> {:ok, body |> Map.get("_source")}
    end
  end
end
