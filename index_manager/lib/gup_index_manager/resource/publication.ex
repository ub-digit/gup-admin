defmodule GupIndexManager.Resource.Publication do
  alias GupIndexManager.Model.Publication
  alias GupIndexManager.Resource.Index

  def create_or_update(data) do
    id = Map.get(data, "id")
    attended = Map.get(data, "attended", :attended_not_found)
    data = data |> Map.put("origin_id", String.split(id, "_") |> List.last())

    {attended, deleted} = get_attended_deleted(id, attended)
    db_publication = Publication.find_by_publication_id(id)

    attrs = %{
      "json" => data |> set_open_access() |> Jason.encode!(),
      "attended" => attended,
      "deleted" => deleted,
      "publication_id" => id
    }

    db_publication
    |> Publication.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()

    Index.update_publication(attrs)
  end

  def set_open_access(data) do
    data = build_id_link_pairs(data)
    |> check_for_open_access()
    |> set_open_access_state(data)
    |> Map.put("last_oa_check", DateTime.utc_now() |> DateTime.to_iso8601())
    |> IO.inspect(label: "Data with Open Access State Set")
  end

  defp build_id_link_pairs(data) do
    identifier_links =
    Map.get(data, "identifiers", [])
    # |> IO.inspect(label: "Identifiers from Data")
      |> Enum.filter(fn identifier -> identifier["code"] == "doi" end)
      |> Enum.map(fn identifier ->
        link = "https://dx.doi.org/#{identifier["value"]}"
        {identifier["value"], link}
      end)


    publication_links =
      Map.get(data, "publication_links", [])
      |> Enum.map(fn link ->
        case Regex.run(~r/10\.\S+\/\S+/, link) do
          [doi] ->
            {doi, link}
          _ -> nil
        end
      end)
      # remove nil values
      |> Enum.filter(& &1)

    (identifier_links ++ publication_links)
  end

  defp check_for_open_access(doi_link_pairs) do
    email = Application.get_env(:gup_index_manager, :unpaywall_email, "lassobosso@hotmail.com")
    doi_link_pairs
    |> Enum.map(fn {doi, link} ->
      HTTPoison.get("https://api.unpaywall.org/v2/#{doi}?email=#{email}")
      |> case do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          is_oa = body |> Jason.decode!() |> Map.get("is_oa", false)
          {doi, link, is_oa}
        {:ok, %HTTPoison.Response{status_code: 404}} -> {doi, link, false}
        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect("Error checking open access for doi #{doi}: #{reason}")
          {doi, link, false}
      end
    end)
  end

  defp set_open_access_state(doi_links, data) do
    publications_links = Map.get(data, "publication_links", [])
    |> # filter out doi links from publication_links with regex
      Enum.filter(fn link ->
        not Regex.match?(~r/10\.\S+\/\S+/, link)
      end)

    new_doi_links = Enum.map(doi_links, fn {_doi, link, is_oa} ->
      case is_oa do
        true -> link <> "?open_access=true"
        false -> link
      end
    end)
    # combine new_doi_links with publications_links and remove duplicates
    publications_links = (new_doi_links ++ publications_links)
    |> Enum.uniq()

    Map.put(data, "publication_links", publications_links)
  end


  # def set_open_access(data) do
  #   data
  #   |> get_links()
  #   |> check_for_doi_links()
  #   |> check_for_open_access()
  # end

  # def get_links(data) do
  #   doi_links = data["identifiers"]
  #   |> Enum.filter(fn identifier -> identifier["code"] == "doi" end)
  #   |> Enum.map(fn identifier ->
  #     "https://dx.doi.org/#{identifier["value"]}"  #TODO: regex to validate doi value
  #   end)
  #   publications_links = doi_links ++ Map.get(data, "publications_links", []) |> Enum.uniq()
  # end

  # def check_for_doi_links(links) do
  #   Enum.filter(links, fn link -> Regex.match?(~r/10\.\S+\/\S+/, link) end)
  # end

  # def check_for_open_access(links) do
  #   # for each link in links, check if it is open access by making a request to Unpaywall API
  #   # if any of the links is open access, return true
  #   email = Application.get_env(:gup_index_manager, :unpaywall_email, "lassobosso@hotmail.com")
  #   links
  #   |> get_doi_from_link()
  #   |> Enum.map(fn doi ->
  #     HTTPoison.get("https://api.unpaywall.org/v2/#{doi}&email=#{email}")
  #     |> case do
  #       {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #         body
  #         |> Jason.decode!() |> Map.get("is_oa", false)
  #         |> case do
  #           true ->
  #           false -> false
  #         end
  #       {:ok, %HTTPoison.Response{status_code: 404}} -> false
  #       {:error, %HTTPoison.Error{reason: reason}} ->
  #         IO.inspect("Error checking open access for doi #{doi}: #{reason}")
  #         false
  #     end
  #   end)
  # end

  # def get_doi_from_link(links) do
  #   links
  #   |> Enum.map(fn link ->
  #     case Regex.run(~r/10\.\S+\/\S+/, link) do
  #       [doi] -> doi
  #       _ -> nil
  #     end
  #   end)
  #   |> Enum.filter(& &1) # remove nil values
  # end

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
    first_name =
      Map.get(author, "person")
      |> List.first()
      |> Map.get("first_name")
      |> case do
        nil -> ""
        first_name -> first_name
      end

    last_name =
      Map.get(author, "person")
      |> List.first()
      |> Map.get("last_name")
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

  def t do
    IO.inspect("Testing Open Access Check")
  end
end
