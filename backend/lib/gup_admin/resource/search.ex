# this module will query elasticsearch for posts with filter on origin
defmodule GupAdmin.Resource.Search do
  @index "publications"
  alias GupAdmin.Resource.Search.Query
  alias GupAdmin.Resource.Search.Filter
  # get elastic url from config
  def elastic_url do
    System.get_env("ELASTIC_URL") || "http://localhost:9200"
  end

  def show(id) do
    q = Query.base("")
    |> put_in(["query", "bool", "filter"],  %{"match" => %{"id" => id}})
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> remap()
    |> List.first()
  end

  def search(params) do
    params = remap_params(params)
    q = Query.base(params["title"])
    |> Filter.add_filter(Filter.build_filter(params["filter"]))
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> remap()
  end

  def remap_params(params) do
    %{
      "title" => params["title"] || "",
      "filter" => clense_filter(params)
    }
  end

  def clense_filter(params) do
    params
    |> IO.inspect(label: "params")
    %{
      "source" => get_source_list(params),
      "pubtype" => params["pubtype"] || nil,
      #"needs_attention" => params["needs_attention"] || nil,
    }
    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
    |> Enum.filter(fn {_, val} -> validate_parameter(val) end)
  end

  def validate_parameter(val) when is_list(val), do: true
  def validate_parameter(val) when is_integer(val), do: val > 0
  def validate_parameter(val) when is_bitstring(val), do: String.length(val) > 0


  def get_source_list(params) do
    list = [
      {"wos", params["wos"] || nil},
      {"scopus", params["scopus"] || nil},
      {"manual", params["manual"] || nil}
    ]
    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
    |> Enum.map(fn {name, _} -> name end)

    case length(list) do
      0 -> nil
      _ -> list
    end
  end

  def remap(hits) do
    hits
    |> Enum.map(fn hit -> hit["_source"] end)
  end
end
