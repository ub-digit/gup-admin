defmodule GupAdmin.Resource.Publication do
  alias GupAdmin.Resource.Search
  # post to external site with httpoison
  def post_publication_to_gup(id) do
    url = "http://localhost:4000/api/v1/publications"
    body = show(id) |> Jason.encode!()
    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])

  end

  def show(id) do
    Search.search_one(id)
    |> remap()
    |> Map.get("data")
    |> List.first()
    |> case do
      nil -> :error
      res -> res
    end
  end

  def remap(hits) do
    hits = hits
    |> Enum.map(fn hit -> hit["_source"] end)

    total = length(hits)
    data = Enum.take(hits, 50)
    showing = length(data)
    %{
      "total" => total,
      "data" => data,
      "showing" => showing
    }
  end
end
