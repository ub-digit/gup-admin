# this module will query elasticsearch for posts with filter on origin
defmodule GupAdmin.Resource.Search do
  @index "publications"
  @persons_index "persons"
  @query_limit 500
  alias GupAdmin.Resource.Search.Query
  alias GupAdmin.Resource.Search.Filter
  alias GupAdmin.Resource.Publication
  # get elastic url from config
  def elastic_url do
    url = System.get_env("ELASTICSEARCH_URL") || "http://localhost:9200"
    url
  end

  def search(params) do
    case Elastix.Index.exists?(elastic_url(), @index) do
      {:ok, false} -> %{"status" => "error", "message" => "Index does not exist"}
      {:ok, true} -> search_index(params)
    end
  end

  def search_index(params) do
    params = remap_params(params)
    q = Query.base(params["query"])
    |> Filter.add_filter(Filter.build_filter(params["filter"]))
    {:ok, %{body: %{"hits" => hits}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    total = Map.get(hits, "total") |> Map.get("value")
    hits = Map.get(hits, "hits")
    {hits, total}
    |> Publication.remap(params["limit"])
  end

  def remap_params(params) do
    %{
      "query" => params["query"] || "",
      "filter" => clense_filter(params),
      "limit" => params["limit"] || 50
    }
  end

  def clense_filter(params) do
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
    case Elastix.Index.exists?(elastic_url(), @index) do
      {:ok, false} -> %{"status" => "error", "message" => "Index does not exist"}
      {:ok, true} -> search_one(id, :index_exists)
    end
  end

  def search_one(id, :index_exists) do
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], Query.show_base(id))
    hits
  end

  def get_duplicates(%{"mode" => "id", "id" => id}) do
    post = Publication.show_raw(id)
    case post do
      :error -> %{"code" => "404", "statusMessage" => "Post not found"}
      _ ->
        post["publication_identifiers"]
        |> Query.find_duplicates_by_identifiers()
        |> case do
          nil -> []
          query -> get_duplicates(query, id, :has_identifiers)
        end
        |> Publication.remap()
    end

  end

  def get_duplicates(%{"mode" => "title", "id" => id, "title" => title}) do
    #post = Publication.show_raw(id)
    q = title
    |> Query.fuzzy()
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], q)
    hits
    |> Enum.filter(fn p -> p["_id"] != id end)
    |> Enum.filter(fn p -> p["_source"]["source"] == "gup" end)
    |> Publication.remap()
  end

  def get_duplicates(query, id, :has_identifiers) do
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @index, [], query)
    hits
    |> Enum.filter(fn p -> p["_id"] != id end)
    |> Enum.filter(fn p -> p["_source"]["source"] == "gup" end)
  end

  def mark_as_deleted(id) do
    Publication.show_raw(id)
    |> case do
      :error -> :error
      res -> update_index(res)
    end
  end

  def update_index(publication) do
    base_url = System.get_env("GUP_INDEX_MANAGER_URL")
    api_key = System.get_env("GUP_INDEX_MANAGER_API_KEY")
    url = "#{base_url}/publications/#{publication["id"]}?api_key=#{api_key}"
    HTTPoison.delete(url, [{"Content-Type", "application/json"}])
  end
  # TODO: Move to query module
  def search_departments(%{"query" => query}) do


    q = %{
      "track_total_hits" => true,
      "size" => 50,
      "query" => %{
        "bool" => %{
          "must" => [
            if String.trim(query) == "" do
              %{"match_all" => %{}}
            else
              %{
                "query_string" => %{
                  "default_operator" => "AND",
                  "fields" => ["name_sv^15", "name_en^15", "orgdbid^10"],
                  "query" => query
                }
              }
            end
          ]
        }
      },
      "sort" => if String.trim(query) == "" do
                  [%{"updated_at" => %{"order" => "desc"}}]
                else
                  []
                end
    }







    {:ok, %{body: %{"hits" => hits}}} = Elastix.Search.search(elastic_url(), "departments", [], q)
    data = hits
    |> Map.get("hits")
    |> Enum.map(fn dep -> Map.get(dep, "_source") end)
    %{
      "total" => Map.get(hits, "total") |> Map.get("value"),
      "data" => data,
      "showing" => length(data)
    }
  end

  def get_person(id) do
    query = %{
      "query" => %{
      "bool" => %{
        "must" => [
        %{
          "term" => %{
          "id" => id
          }
        }
        ],
        "must_not" => [
          %{
            "term" => %{
              "deleted" => true
            }
          }
        ]
      }
      }
    }

    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(elastic_url(), @persons_index, [], query)
    data = hits
    |> Enum.map(fn dep -> Map.get(dep, "_source") end)
    data = Enum.take(data, 1)
    |> sort_names_on_primary()
    |> sort_person_departments_on_current()
    |> List.first()
    %{
      "data" => data
    }

  end



  defp persons_search_result(query) do
    {:ok, %{body: %{"hits" => hits}}} = Elastix.Search.search(elastic_url(), @persons_index, [], query)
    data = hits
      |> Map.get("hits")
      |> Enum.take(50)
      |> Enum.map(fn dep -> Map.get(dep, "_source") end)
      |> sort_names_on_primary()
      |> sort_person_departments_on_current()
    %{
      "total" => Map.get(hits, "total") |> Map.get("value"),
      "data" => data,
      "showing" => length(data)
    }
  end

  def get_all_persons() do
    # query = %{
    #   "track_total_hits" => true,
    #   "size" => @query_limit,
    #   "query" => %{
    #     "bool" => %{
    #       "must" => %{
    #         "match_all" => %{}
    #       },
    #       "must_not" => %{
    #         "term" => %{
    #           "deleted" => true
    #         }
    #       }
    #     }
    #   }
    # }

    query = %{
      "track_total_hits" => true,
      "size" => @query_limit,
      "query" => %{
        "bool" => %{
          "must" => %{
            "match_all" => %{}
          },
          "must_not" => %{
            "term" => %{
              "deleted" => true
            }
          }
        }
      },
      "sort" => [
        %{
          "updated_at" => %{
            "order" => "desc"
          }
        }
      ]
    }
    persons_search_result(query)
  end

  def search_persons("") do
    get_all_persons()
  end

  def search_persons(query) do
    query = Query.search_persons(query)
    IO.inspect(query, label: "search_persons query")
    Elastix.Search.search(elastic_url(), @persons_index, [], query)
    persons_search_result(query)
  end


  def search_persons_gup_person_ids(ids) do
    query = Query.search_persons_gup_person_ids(ids)
    IO.inspect(ids, label: "search_persons_gup_person_ids ids")
    Elastix.Search.search(elastic_url(), @persons_index, [], query)
    persons_search_result(query)
  end

  def get_person_count do
   {:ok, %{body: body}} = Elastix.Search.count(elastic_url(), @persons_index, [], %{})
   body |> Map.get("count")
  end

  def sort_names_on_primary(data) do
    Enum.map(data, fn person ->
      names = Map.get(person, "names", [])
      |> Enum.sort_by(&(&1["primary"]))
      Map.put(person, "names", names |> Enum.reverse())
    end)
  end

  def sort_person_departments_on_current(data) do
    Enum.map(data, fn person ->
      departments = Map.get(person, "departments", [])
      |> Enum.sort_by(&(&1["current"]))
      Map.put(person, "departments", departments |> Enum.reverse())
    end)
  end


  def get_merged_persons() do
    search_merged_persons("")
  end

  def get_merged_persons(term) do
    search_merged_persons(term)
  end

  def search_merged_persons(term) do
    # get all persons with name_count > 1
    query = Query.search_merged_persons(term)
    {:ok, %{body: %{"hits" => hits}}} = Elastix.Search.search(elastic_url(), @persons_index, [], query)
    data = hits
    |> Map.get("hits")
    |> Enum.take(50)
    |> Enum.map(fn dep -> Map.get(dep, "_source") end)
    |> sort_names_on_primary()
    |> sort_person_departments_on_current()
    %{
      "total" => Map.get(hits, "total") |> Map.get("value"),
      "data" => data,
      "showing" => length(data)
    }

  end
end
