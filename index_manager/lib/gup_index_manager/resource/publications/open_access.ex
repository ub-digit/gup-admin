defmodule GupIndexManager.Resource.Publications.OpenAccess do
  defp oa_check_interval_days, do: String.to_integer(System.fetch_env!("OPEN_ACCESS_CHECK_INTERVAL_DAYS"))
  defp unpaywall_email, do: System.fetch_env!("UNPAYWALL_EMAIL")

  def set_open_access_link_status(json_map) do
    doi_identifiers = get_doi_idenifiers_values(json_map)

    publications_links =
      Map.get(json_map, "publication_links", [])
      |> add_non_existing_doi_links_to_publications_links(doi_identifiers)
      |> check_and_set_open_access_state_for_doi_links()

    # return the json map with updated publication_links
    Map.put(json_map, "publication_links", publications_links)
  end

  def set_publication_open_access_status(json_map) do
    publications_open_access_status =
      json_map
      |> Map.get("publication_links", [])
      |> Enum.any?(fn link -> link_is_open_access(link) end)

    Map.put(json_map, "is_open_access", publications_open_access_status)
  end

  defp link_is_open_access(link) do
    case Map.get(link, "is_oa", nil) do
      true -> true
      false -> false
      nil -> false
    end
  end

  defp get_doi_idenifiers_values(data) do
    Map.get(data, "identifiers", [])
    |> Enum.filter(fn identifier -> identifier["code"] == "doi" end)
    |> Enum.map(fn identifier -> Map.get(identifier, "value") end)
  end

  defp get_next_link_position(publication_links) do
    publication_links
    |> Enum.map(fn link -> Map.get(link, "position", 0) end)
    # if publication_links is empty, start with position 0
    |> Enum.max(fn -> 0 end)
    # next position will be max position + 1
    |> Kernel.+(1)
  end

  defp add_non_existing_doi_links_to_publications_links(publication_links, doi_identifiers) do
    non_existing_doi_links =
      doi_identifiers
      |> Enum.filter(fn doi ->
        not Enum.any?(publication_links, fn link ->
          Regex.match?(~r/10\.\S+\/\S+/, link["url"]) and
            Regex.run(~r/10\.\S+\/\S+/, link["url"]) |> List.first() == doi
        end)
      end)

    Enum.reduce(non_existing_doi_links, publication_links, fn doi, acc ->
      acc ++
        [
          %{
            "url" => "https://dx.doi.org/#{doi}",
            "is_oa" => nil,
            "last_checked" => nil,
            "position" => get_next_link_position(acc)
          }
        ]
    end)
  end

  defp check_and_set_open_access_state_for_doi_links(publication_links) do
    Enum.map(publication_links, fn link ->
      # send to should_check_oa?
      case Map.has_key?(link, "is_oa") and time_to_check_open_access?(link) do
        # check oa_state at unpaywall.
        true ->

          state = get_open_access_state_from_unpaywall(link)
          Map.put(link, "is_oa", Map.get(state, "is_oa", nil))
          |> Map.put("last_checked", Date.utc_today() |> Date.to_iso8601())
        false ->
          # if link does not have is_oa key, return it as is
          link
      end
    end)
  end

  defp time_to_check_open_access?(link) do
    case Map.get(link, "last_checked") do
      # if never checked, we should check it
      nil -> true
      last_checked ->
        date_diff = Date.utc_today() |> Date.diff(Date.from_iso8601!(last_checked))
        date_diff >= oa_check_interval_days()
    end
  end

  def get_open_access_state_from_unpaywall(link) do
    doi_id = Regex.run(~r/10\.\S+\/\S+/, link["url"]) |> List.first()
    is_oa = HTTPoison.get("https://api.unpaywall.org/v2/#{doi_id}?email=#{unpaywall_email()}")
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        is_oa = body
        |> Jason.decode!()
        |> Map.get("is_oa", nil)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        # return existing is_oa value if error occurs
        Map.get(link, "is_oa", nil)
    end
    Map.put(link, "is_oa", is_oa)
  end
end
