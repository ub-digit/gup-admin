# this module will query elasticsearch for posts with filter on origin
defmodule GupAdmin.Resource.Search do
  @index "publications"
  alias GupAdmin.Resource.Search.Query
  alias GupAdmin.Resource.Search.Filter
  alias GupAdmin.Resource.Publication
  # get elastic url from config
  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL") || "http://localhost:9200"
  end

  def search(params) do
    params = remap_params(params)
    q = Query.base(params["title"])
    |> Filter.add_filter(Filter.build_filter(params["filter"]))
    |> IO.inspect(label: "query")
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> Publication.remap()
  end

  def remap_params(params) do
    %{
      "title" => params["title"] || "",
      "filter" => clense_filter(params)
    }
  end

  def clense_filter(params) do
    IO.inspect(params, label: "clense_filter params")
    %{
      "source" => get_source_list(params),
      # TBD: Have frontend send pubtype_id instead of pubtype_code?
      "publication_type_id" => get_pub_type_id(params["pubtype"]) || nil,
      "attended" => get_attended_param(params),
      "deleted" => params["deleted"] || false,
      "pubyear" => params["year"] || nil
    }

    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
    |> Enum.filter(fn {_, val} -> validate_parameter(val) end)
    |> Enum.into(%{})
    |> IO.inspect(label: "clense_filter")

  end

  def get_attended_param(params) do
    attended = params["needs_attention"]
    case attended do
      true -> false
      false -> true
      _ -> nil
    end
  end

  def get_pub_type_id(nil), do: nil
  def get_pub_type_id(""), do: nil
  def get_pub_type_id(pubtype_code) do
    GupAdmin.Resource.PublicationType.get_publication_types()
    |> Enum.find(fn pt -> pt["publication_type_code"] == pubtype_code end)
    |> Map.fetch!("publication_type_id")
  end

  def validate_parameter(val) when is_list(val), do: true
  def validate_parameter(val) when is_integer(val), do: val > 0
  def validate_parameter(val) when is_bitstring(val), do: String.length(val) > 0
  def validate_parameter(val) when is_boolean(val), do: true
  def validate_parameter(:error), do: false


  def get_source_list(params) do
    list = [
      {"wos", params["wos"] || nil},
      {"scopus", params["scopus"] || nil},
      #{"manual", params["manual"] || nil},
      {"gup", params["gup"] || params["manual"] || nil},
    ]
    |> Enum.filter(fn {_, val} -> not is_nil(val) end) # remove nils
    |> Enum.filter(fn {_, val} -> not is_binary(val) end) # remove binaries
    |> Enum.filter(fn {_, val} -> val != :error end) # remove :error values
    |> Enum.map(fn {name, _} -> name end)

    case length(list) do
      0 -> nil
      _ -> list
    end
  end

  def search_one(id) do
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], Query.show_base(id))
    hits
  end

  def get_duplicates(%{"mode" => "id", "id" => id}) do
    post = Publication.show_raw(id)
    q = post["publication_identifiers"]
    |> Query.find_duplicates_by_identifiers()
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> Enum.map(fn i -> Map.get(i, "_source") end)
  end

  def get_duplicates(%{"mode" => "title", "id" => id}) do
    post = Publication.show_raw(id)
    q = post["title"]
    |> Query.fuzzy()
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> Enum.map(fn i -> Map.get(i, "_source") end)
  end

  def mark_as_deleted(id) do
    Publication.show_raw(id)
    |> case do
      :error -> :error
      res -> update_index(res)
    end
  end

  def update_index(post) do
    post = post
    |> Map.put("deleted", true)
    |> Map.put("needs_attention", false)
    |> Map.put("deleted_at", DateTime.utc_now())
    |> IO.inspect(label: "post")
    Elastix.Document.index(elastic_url(), @index, "_doc", post["id"], post)
    {:ok, %{body: _}} = Elastix.Index.refresh(elastic_url(), @index)
    %{"message" => "Publication marked as deleted"}
  end
end
