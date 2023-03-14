# this module will query elasticsearch for posts with filter on origin
defmodule GupAdmin.Resource.Search do
  @index "publications"
  alias GupAdmin.Resource.Search.Query
  alias GupAdmin.Resource.Search.Filter
  # get elastic url from config
  def elastic_url do
    System.get_env("ELASTIC_URL") || "http://localhost:9200"
  end

  def search(params) do
    params = remap_params(params)
    q = Query.base(params["title"])
    |> Filter.add_filter(Filter.build_filter(params["filter"]))
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
  end

  def remap_params(params) do
    %{
      "title" => params["title"] || "",
      "filter" => clense_filter(params)
    }
  end

  def clense_filter(params) do
    %{
      "source" => get_source_list(params),
      "pubtype" => params["pubtype"] || nil,
      "needs_attention" => params["needs_attention"] || nil,
    }
    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
  end

  def get_source_list(params) do
    [
      {"wos", params["wos"] || nil},
      {"scopus", params["scopus"] || nil},
      {"manual", params["manual"] || nil}
    ]
    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
    |> Enum.map(fn {name, _} -> name end)
  end
end
