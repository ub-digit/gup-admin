defmodule GupIndexManager.Resource.Publication do
  alias GupIndexManager.Model.Publication
  alias GupIndexManager.Resource.Index

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
      {:error, _} -> {attended, false}
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
      "publication_id" => db_publication.publication_id,
      "updated_at" => DateTime.utc_now()
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

  # identifiers is a list of strings which will be
  # converted to a list of maps with keys "code" and "value"
  # String is of format "orcid:0000-0001-2345-6789", "scopus_id:123456789", etc.
  def check_identifiers(identifiers) do
    # Convert list of strings to list of maps with "code" and "value"
    identifiers = Enum.map(identifiers, fn identifier ->
      case String.split(identifier, ":") do
        [code, value] -> %{"code" => code, "value" => value}
        _ -> nil
      end
    end)
    Index.check_identifiers(identifiers)
    # Return true if there are publications, otherwise false
    |> case do
      {:ok, []} -> false
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
