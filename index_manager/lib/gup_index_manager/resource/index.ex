defmodule GupIndexManager.Resource.Index do
  alias Elastix.Index
  alias GupIndexManager.Resource.Index.Config
  alias GupIndexManager.Model
  require Logger
  import Ecto.Query
  @publications_index "publications"
  @departments_index "departments"

  def elastic_url, do: System.get_env("ELASTICSEARCH_URL", "http://localhost:9200")

  def get_indexes do
    [get_persons_index(), @publications_index, @departments_index]
  end

  # ----------------------------- Rebuild index bulk -----------------------------
  def rebuild_publication_index_bulk(limit \\ 10000, offset \\ 0) do
    Logger.info("Rebuilding index posts #{offset} to #{offset + limit}")
    # Fetch publication range from the database
    from(p in Model.Publication, select: p, limit: ^limit, offset: ^offset)
    |> GupIndexManager.Repo.all()
    |> build_bulk_rows()
    |> bulk_index(limit, offset)
  end

  def build_bulk_rows([]), do: {:ok, "Done"}
  def build_bulk_rows(publications) do
    publications
    |> remap_for_index()
    |> remap_for_bulk(@publications_index)
  end

  def remap_for_bulk(data, index) do
    Enum.map(data, fn publication ->
      [%{"index" =>  %{"_index" => index, "_id" => publication["id"]}},
      publication]
    end)
    |> List.flatten()
  end

  def bulk_index({:ok, "Done"}, _, _), do: {:ok, "Done"}
  def bulk_index(index_data, limit, offset) do
    Elastix.Bulk.post(elastic_url(), index_data)
    offset = offset + limit
    rebuild_publication_index_bulk(limit, offset)
  end

  # --------------------------------------------------------------------------------

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
  def rebuild_index() do
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

  def update_department(attrs) do
    json = attrs
    |> Map.get("json")
    |> Jason.decode!()
    |> Map.put("created_at", attrs["inserted_at"])
    |> Map.put("updated_at", attrs["updated_at"])

    Elastix.Document.index(elastic_url(), @departments_index, "_doc", attrs["id"], json, [])
    |> case do
      {:ok, %{body: %{ "error" => error}}} -> {:error, error}
      {:ok, _} -> {:ok, "ok"}
    end
    |> case do
      {:error, error} -> %{"error" => error}
      {:ok, _} ->
        Elastix.Index.refresh(elastic_url(), @departments_index)
        |> case do
          {:ok, %{body: %{ "error" => error}}} -> {:error, error}
          {:ok, _} -> %{"status" => "ok"}
        end
    end
  end

  def reindex_departments() do
    # reset index
    reset_index(@departments_index)

    # Get all departments from the database
    index_data = Model.Department |> GupIndexManager.Repo.all()
    # Create a map with id as key
    |> Enum.reduce(%{}, fn department, acc ->
      Map.put(acc, department.id, %{
        id: department.id,
        parent_id: department.parent_id,
        is_faculty: department.is_faculty,
        data: Jason.decode!(department.json) |> Map.put("created_at", department.inserted_at) |>
          Map.put("updated_at", department.updated_at)
      })
    end)

    # Create a list of items with hierarchy
    |> hierarchy_map()
    # Map the items to the format required for bulk indexing
    |> Enum.map(fn item ->
      [%{"index" =>  %{"_index" => @departments_index, "_id" => Map.get(item, "id")}}, item]
    end)
    |> List.flatten()
    Elastix.Bulk.post(elastic_url(), index_data)
    Elastix.Index.refresh(elastic_url(), @departments_index)
    |> IO.inspect(label: "Bulk index response")
  end

      # Loop over all data in a map (with id as key)
  # like this:
  # %{1 => %{id: 1, parent_id: nil, is_faculty: true, data: %{name: "Faculty of Science"}},
  #   2 => %{id: 2, parent_id: nil, is_faculty: true, data: %{name: "Faculty of Arts"}},
  #   3 => %{id: 3, parent_id: nil, is_faculty: true, data: %{name: "Faculty of Engineering"}},
  #   4 => %{id: 4, parent_id: 1, is_faculty: false, data: %{name: "Department of Physics"}},
  #   ...
  #   15 => %{id: 15, parent_id: 6, is_faculty: false, data: %{name: "Molecular Biology Department"}}
  # }
  # Create a list of items where each item has the format:
  # %{id: id, hierarchy: [id1, id2, ...], is_faculty: is_faculty, name: name}
  # Hierarchy is a list of ids from the root to the item's parent (it should NOT include the item itself)
  def hierarchy_map(input_map) do
    input_map
    |> Enum.reduce([], fn {id, item}, acc ->
      hierarchy = get_hierarchy(input_map, id, item)
      # Remove the item id from the hierarchy
      hierarchy = List.delete(hierarchy, id)
      # Reverse the hierarchy to get the order from root to item
      hierarchy = Enum.reverse(hierarchy)
      # Add the hierarchy to the item
      item_data = Map.get(item, :data)
      [Map.put(item_data, :hierarchy, hierarchy) | acc]
    end)
  end

  # Get the hierarchy for a given item
  defp get_hierarchy(input_map, id, item) do
    case item.parent_id do
      nil -> [id]
      parent_id ->
        parent_item = Map.get(input_map, parent_id)
        if parent_item do
          [id | get_hierarchy(input_map, parent_id, parent_item)]
        else
          [id]
        end
    end
  end
 end
