defmodule GupAdmin.Resource.Publication do
  alias GupAdmin.Resource.Search

  def index_manager_base_url do
    System.get_env("GUP_INDEX_MANAGER_URL") || "http://localhost:4010"
  end

  def gup_base_url do
    System.get_env("GUP_URL") || "https://gup-server-lab.ub.gu.se/"
  end

  # post to external site with httpoison
  def post_publication_to_gup(id, gup_user) do
    api_key = System.get_env("GUP_API_KEY", "an-api-key")
    url = "#{gup_base_url()}v1/drafts_admin?api_key=#{api_key}&username=#{gup_user}"
    pub = show_raw(id)
    body = %{"publication" => pub} |> Jason.encode!()
    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
  end

  def merge_publications(gup_id, publication_id, gup_user) do
    api_key = System.get_env("GUP_API_KEY", "an-api-key")
    gup_id = gup_id |> String.split("_") |> List.last()
    url =  "#{gup_base_url()}v1/published_publications_admin/#{gup_id}?api_key=#{api_key}&username=#{gup_user}"
    publication_identifiers = show_raw(publication_id)
    |> Map.get("publication_identifiers")
    |> IO.inspect(label: "publication_identifiers")
    body = %{"publication" => %{"publication_identifiers" => publication_identifiers}, "id" => gup_id} |> Jason.encode!()
    HTTPoison.put(url, body, [{"Content-Type", "application/json"}])
    |> IO.inspect(label: "merge_publications")
    {:ok, %{"message" => "Publication with id #{publication_id} merged with publication with id #{gup_id}"}}
  end

  def show(id) do
    Search.search_one(id)
    |> List.first()
    |> case do
      nil -> :error
      res -> res |> Map.get("_source") |> remap("new") |> clear_irrelevant_identifiers()
    end
  end

  def show(id, :dont_clear_irrelevant_identifiers) do
    Search.search_one(id)
    |> List.first()
    |> Map.get("_source")
    |> remap("new")
  end

  def show_raw(id) do
    Search.search_one(id)
    |> List.first()
    |> case do
      nil -> :error
      hits -> hits |> Map.get("_source")
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

  def get_publication_id(data) do
    String.split(data["id"], "_") |> List.last()
  end

  def remap(data, "new") do
    []
    |> row(get_publication_id(data), [{"display_label", "publication_id"}, {"display_type", "string"}, {"visibility", get_visibility("publication_id")}])
    |> row(data["id"], [{"display_label", "id"}, {"display_type", "string"}, {"visibility", get_visibility("id")}])
    |> row(%{"url" => get_publication_url(data), "title" => data["title"]}, [{"display_label", "title"}, {"display_type", "title"}, {"visibility", get_visibility("title")}])
    |> row(meta_data(data), [{"display_type", "meta"}, {"visibility", get_visibility("meta")}])
    |> row(data["publication_type_label"], [{"display_label", "publication_type_label"}, {"display_type", "string"}, {"visibility", get_visibility("publication_type_label")}])
    |> row(data["sourcetitle"], [{"display_label", "sourcetitle"}, {"display_type", "string"}, {"visibility", get_visibility("sourcetitle")}])
    |> row(data["pubyear"], [{"display_label", "pubyear"}, {"display_type", "string"}, {"visibility", get_visibility("pubyear")}])
    |> row(volume_issue_pages(data), [{"display_label", "sourceissue_sourcepages_sourcevolume"}, {"display_type", "sourceissue_sourcepages_sourcevolume"}, {"visibility", get_visibility("sourceissue_sourcepages_sourcevolume")}])
    |> row(get_authors(data), [{"display_label", "authors"}, {"display_type", "authors"}, {"visibility", get_visibility("authors")}])
    |> get_publication_identifier_rows("first", data)
  end

  def meta_data(data) do
    %{
      "attended" => get_value_block(data["attended"], "attended"),
      "created_at" => get_value_block(data["created_at"], "created_at"),
      "version_created_by" => get_value_block(data["version_created_by"], "version_created_by"),
      "updated_at" => get_value_block(data["updated_at"], "updated_at"),
      "version_updated_by" => get_value_block(data["version_updated_by"], "version_updated_by"),
      "source" => get_value_block(data["source"], "source")
    }
  end

  def volume_issue_pages(data) do
    %{
      "sourcevolume" => data["sourcevolume"] || "missing",
      "sourceissue" => data["sourceissue"] || "missing",
      "sourcepages" => data["sourcepages"] || "missing"
    }
  end

  def compare_posts(id_1, id_2) do
    post_1 = show(id_1, :dont_clear_irrelevant_identifiers)
    post_2 = show(id_2, :dont_clear_irrelevant_identifiers)
    post_1
    |> Enum.with_index()
    |> Enum.map(fn {first, index} ->
      compare(first, Enum.at(post_2, index))
    end)
    |> clear_irrelevant_identifiers()

  end

  def clear_irrelevant_identifiers(%{"seccond" => _} = data) do
    data
    |> Enum.reject(fn row ->
      row["data_type"] == :identifier &&
      row["diff"] == false &&
      row["first"]["value"]["display_title"] == nil
    end)
    |> Enum.map(fn row -> Map.delete(row, "data_type") end)
  end

  def clear_irrelevant_identifiers(data) do
    data
    |> Enum.reject(fn row ->
      row["data_type"] == :identifier &&
      row["first"]["value"]["display_title"] == nil
    end)
    |> Enum.map(fn row -> Map.delete(row, "data_type") end)
  end

  def compare(%{"display_type" => "meta"} = first, %{"display_type" => "meta"} = second) do
    case first === second do
      true -> Map.put(first, "second", Map.get(second, "first"))
      false -> Map.put(first, "second", Map.get(second, "first"))
    end
  end

  def compare(%{"display_type" => "title"} = first, %{"display_type" => "title"} = second) do
    case first === second do
      true -> Map.put(first, "second", Map.get(second, "first"))
      false -> Map.put(first, "second", Map.get(second, "first"))
    end
  end

  def compare(first, second) do
    case first === second do
      true -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", false)
      false -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", true)
    end
  end

  def row(container, value, mutual) do
    container ++
      [
        %{
        "first" => %{
          "value" => value,
        },
      }
      |> add_mutual(mutual)
    ]
  end

  def add_mutual(data, mutual) do
    mutual
    |> Enum.reduce(data, fn item, acc ->
      Map.put(acc, elem(item, 0), elem(item, 1))
    end)
  end

  def get_value_block(value, label) do
    %{
        "value" => value,
        "display_label" => label
      }
  end

  def get_author_block(id, name, x_account) do
    %{
        "id" => id,
        "name" => name,
        "x-account" => x_account
      }
  end

  def get_authors(data) do
    data["authors"]
    |> case  do
      nil -> []
      authors -> authors
    end
    |> Enum.map(fn author -> get_author_block(author["id"], author["name"], author["x-account"]) end)
  end

  def get_publication_identifier_rows(container, order, data) do
    data["publication_identifiers"]
    |> case do
      nil -> []
      identifiers -> identifiers
    end
    |> add_missing_identifiers()
    |> Enum.reduce(container, fn identifier, acc ->
      acc ++
      [%{
        order => %{
          "value" => %{
            "url" => get_identifier_url(identifier),
            "display_title" => identifier["identifier_value"]
          }
        },
        "display_label" => get_identifier_name_code(identifier["identifier_code"]),
        "display_type" => "url",
        "visibility" => get_visibility("identifier"),
        "data_type" => :identifier
      }]
    end)
  end

  def add_missing_identifiers(identifiers) do
    [
      %{
        "identifier_code" => "doi",
        "identifier_value" => nil
      },
      %{
        "identifier_code" => "scopus-id",
        "identifier_value" => nil
      },
      %{
        "identifier_code" => "isi-id",
        "identifier_value" => nil
      },
      %{
        "identifier_code" => "pubmed",
        "identifier_value" => nil
      },
      %{
        "identifier_code" => "libris-id",
        "identifier_value" => nil
      },
      %{
        "identifier_code" => "handle",
        "identifier_value" => nil
      }
    ]
    |> Enum.map(fn default_identifier ->
      Enum.find(identifiers, fn i -> i["identifier_code"] == default_identifier["identifier_code"] end)
      |> case do
        nil -> default_identifier
        identifier -> identifier
      end

    end)
  end

  def get_identifier_name_code(code) do
    case code do
      "doi" -> "doi"
      "scopus-id" -> "scopus"
      "isi-id" -> "isiid"
      "pubmed" -> "pubmed"
      "libris-id" -> "libris"
      "handle" -> "handle"
      _ -> "missing"
    end
  end

  def get_identifier_url(%{"identifier_code" => _, "identifier_value" => nil}), do: nil
  def get_identifier_url(%{"identifier_code" => code, "identifier_value" => value}) do

    code
    |> case do
      "doi" -> "https://dx.doi.org/#{value}"
      "scopus-id" -> "https://www.scopus.com/record/display.uri?eid=2-s2.0-#{value}&origin=resultslist"
      "isi-id" -> "https://www.webofscience.com/wos/woscc/full-record/WOS:#{value}"
      "pubmed" -> "https://pubmed.ncbi.nlm.nih.gov/#{value}"
      _ -> nil
    end
  end

  def get_publication_url(data) do
    sys_id = data["id"]
    id = get_publication_id(data)
    case String.contains?(sys_id, "gup") do
      true -> gup_base_url() <> "/publications/show/#{id}"
      _ -> ""
    end
  end

  def gup_base_url() do
    System.get_env("GUP_BASE_URL", "https://gup-staging.ub.gu.se")
  end

  def get_visibility(display_label) do
    case display_label do
      "title" -> "always"
      "meta" -> "always"
      "publication_type_label" -> "always"
      "sourcetitle" -> "always"
      "pubyear" -> "always"
      "sourceissue_sourcepages_sourcevolume" -> "always"
      "authors" -> "always"
      "identifier" -> "always"
      _ -> "never"
    end
  end
end
