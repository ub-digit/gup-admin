defmodule GupIndexManager.Resource.Publication do
  alias GupIndexManager.Model.Publication
  alias GupIndexManager.Resource.Index
  def create_or_update(data) do
    id = data |> get_id()
    attrs = %{
      "json" => data |> Jason.encode!(),
      "attended" => false, #need to check database if fot attanded flag?
      "publication_id" => id
    }

    Publication.find_by_publication_id(id)
    |> Publication.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    Index.add_publication(attrs)
  end

  def list() do
    Publication
    |> GupIndexManager.Repo.all()
    |> remap()
  end

  def remap(publications) do
    Enum.map(publications, fn publication ->
      %{
        "publication_id" => publication.publication_id,
        "json" => String.slice(publication.json, 0, 100) <> "..."
      }
    end)
  end

  def get_id(data) do
    data |> Map.get("id")
  end

  def get_all_publications() do
    Publication
    |> GupIndexManager.Repo.all()
  end
end
