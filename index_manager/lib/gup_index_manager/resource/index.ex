defmodule GupIndexManager.Resource.Index do
  alias Elastix.Index
  alias GupIndexManager.Resource.Index.Config
  alias GupIndexManager.Model
  @publications_index "publications"
  @departments_index "departments"

  def elastic_url, do: System.get_env("ELASTICSEARCH_URL", "http://localhost:9200")

  def get_indexes do
    [get_persons_index(), @publications_index, @departments_index]
  end

  def reset_index(index) do
    Enum.member?(get_indexes(), index)
    |> case do
      true ->
        delete_index(index)
        create_index(index)
      false -> {:error, "Index \"#{index}\" is not a valid index"}
    end
  end

  def delete_index(index) do
    Index.delete(elastic_url(), index)
  end

  def get_persons_index, do: Application.get_env(:gup_index_manager, :person_index_name)
  def get_publications_index, do: @publications_index
  def get_departments_index, do: @departments_index

  def create_index(index), do: create_index(index, Elastix.Index.exists?(elastic_url(), index))
  def create_index(index, {:ok, true}), do: {:ok, "Index: #{index} already exists"}
  def create_index(_index, {:error, error}), do: {:error, error}
  def create_index(index, {:ok, false}) do
    IO.puts("Creating index: #{index}")
    Index.create(elastic_url(), index, get_config(index))
    |> case do
      {:ok, %{body: %{"error" => reason}}} -> {:error, reason}
      {:ok, res} -> {:ok, res}
      {:error, error} -> {:error, error}
    end
  end

  defp get_config(@publications_index), do: Config.publications_config()
  defp get_config(@departments_index), do: Config.departments_config()
  defp get_config(_), do: Config.persons_config()



  # TODO: Move to publication resource
  def rebuild_index do
    create_index(@publications_index)
    Model.Publication |> GupIndexManager.Repo.all()
    |> remap_for_index()
    |> Enum.map(fn publication ->
      Elastix.Document.index(elastic_url(), @publications_index, "_doc", publication["id"], publication, [])
    end)
  end

  def remap_for_index(publications) do
    publications
    |> Enum.map(fn publication ->
      publication.json |> Jason.decode!()
      |> Map.put("attended", publication.attended)
      |> Map.put("deleted", publication.deleted)
    end)
  end

  def update_publication(attrs) do
    json = attrs
    |> Map.get("json")
    |> Jason.decode!()
    |> Map.put("attended", attrs["attended"])
    |> Map.put("deleted", attrs["deleted"])

    Elastix.Document.index(elastic_url(), @publications_index, "_doc", attrs["publication_id"], json, [])
    |> case do
      {:ok, %{body: %{ "error" => error}}} -> {:error, error}
      {:ok, _} -> {:ok, "ok"}
    end
    |> case do
      {:error, error} -> %{"error" => error}
      {:ok, _} ->
        Elastix.Index.refresh(elastic_url(), @publications_index)
        |> case do
          {:ok, %{body: %{ "error" => error}}} -> {:error, error}
          {:ok, _} -> %{"status" => "ok"}
        end
    end
  end

  def mark_as_pending(id) do
    #TODO: needs error handling
    {:ok, %{body: body}} = Elastix.Document.get(elastic_url(), @publications_index, "_doc", id)
    body = body
    |> Map.get("_source")
    |> Map.put("pending", true)
    res = Elastix.Document.index(elastic_url(), @publications_index, "_doc", id, body, [])
    Elastix.Index.refresh(elastic_url(), @publications_index)
    res
  end

  def get_publication(id) do
    Elastix.Document.get(elastic_url(), @publications_index, "_doc", id)
    |> case do
      {:ok, %{status_code: 404}} -> {:error, "Not found"}
      {:ok, %{body: body}} -> {:ok, body |> Map.get("_source")}
    end
  end

  def update_record(data, id, index) do
    Elastix.Document.index(elastic_url(), index, "_doc", id, data, [])
    |> case do
      {:ok, %{body: %{ "error" => error}}} -> {:error, error}
      {:ok, _} -> {:ok, "ok"}
    end
    |> case do
      {:error, error} -> %{"error" => error}
      {:ok, _} ->
        Elastix.Index.refresh(elastic_url(), index)
        |> case do
          {:ok, %{body: %{ "error" => error}}} -> {:error, error}
          {:ok, _} -> %{"status" => "ok"}
        end
    end
  end
 end
