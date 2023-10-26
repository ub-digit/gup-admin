defmodule GupIndexManager.Resource.Publication do
  alias GupIndexManager.Model.Publication
  alias GupIndexManager.Resource.Index

  @spec create_or_update(map) :: {:error, any} | %{optional(<<_::40, _::_*8>>) => any}
  def create_or_update(data) do
    id =  Map.get(data, "id")
    attended = Map.get(data, "attended", :attended_not_found)
    data = data |> Map.put("origin_id", String.split(id, "_") |> List.last())

    {attended, deleted} = get_attended_deleted(id, attended)
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

  def get_attended_deleted(id, :attended_not_found) do
    Index.get_publication(id)
    |> case do
      {:ok, pub} -> {pub["attended"] || false, pub["deleted"] || false}
      {:error, _} -> {false, false}
    end
  end

  def get_attended_deleted(id, attended) do
    Index.get_publication(id)
    |> case do
      {:ok, pub} -> {attended, pub["deleted"] || false}
      {:error, _} -> {false, false}
    end
  end

  def delete(id) do
    db_publication = Publication.find_by_publication_id(id)
    case db_publication.id do
      nil -> {:error, "Publication not found"}
      _ -> proceed_delete(db_publication)
    end
  end

  def get_author_name(author) do

    first_name = Map.get(author, "person") |> List.first() |> Map.get("first_name")
    |> case do
      nil -> ""
      first_name -> first_name
    end
    last_name = Map.get(author, "person") |> List.first() |> Map.get("last_name")
    |> case do
      nil -> ""
      last_name -> last_name
    end
    fullname = "#{first_name} #{last_name}"
    String.length(fullname)
    |> case do
      0 -> ""
      _ -> fullname
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

  def mark_as_pending(id) do
    Index.mark_as_pending(id)
  end
end
