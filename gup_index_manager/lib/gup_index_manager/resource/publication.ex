defmodule GupIndexManager.Resource.Publication do
  alias GupIndexManager.Model.Publication
  alias GupIndexManager.Resource.Index
  def create_or_update(data) do
    id =  Map.get(data, "id")
    data = data |> Map.put("origin_id", String.split(id, "_") |> List.last())
    |> remap_authors()
    attended = data |> Map.get("attended", false)
    deleted = data |> Map.get("deleted", false)
    db_publication = Publication.find_by_publication_id(id)

    attrs = %{
      "json" => data |> Jason.encode!(),
      "attended" => attended,
      "deleted" => deleted,
      "publication_id" => id
    }

    db_publication
    |> Publication.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    Index.update_publication(attrs)
  end


  def remap_authors(%{"authors" => [%{"affiliations" => _}]} = data) do
    IO.inspect("remap_authors")
    authors = data
    |> Map.get("authors")
    |> Enum.map(fn author ->
      %{
        "departments" => %{
           "name" => Map.get(author, "affiliations") |> List.first() |> Map.get("department")
        },
        "id" => Map.get(author, "person") |> List.first() |> Map.get("id"),
        "name" => (Map.get(author, "person") |> List.first() |> Map.get("first_name")) <> " " <> (Map.get(author, "person") |> List.first() |> Map.get("last_name"))
      }
    end)
    Map.put(data, "authors", authors)
  end

  def remap_authors(data), do: data

  def delete(id) do
    db_publication = Publication.find_by_publication_id(id)
    case db_publication.id do
      nil -> {:error, "Publication not found"}
      _ -> proceed_delete(db_publication)
    end
  end

  def proceed_delete(db_publication) do
    attrs = %{
      "json" => db_publication.json,
      "attended" => db_publication.attended,
      "deleted" => true,
      "publication_id" => db_publication.publication_id
    }
    db_publication
    |> Publication.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    Index.update_publication(attrs)
  end

  def list() do
    get_all_publications()
    |> remap()
  end

  def remap(publications) do
    Enum.map(publications, fn publication ->
      %{
        "publication_id" => publication.publication_id,
        "attended" => publication.attended,
        "deleted" => publication.deleted
      }
    end)
  end



  def get_all_publications() do
    Publication
    |> GupIndexManager.Repo.all()
  end
end
