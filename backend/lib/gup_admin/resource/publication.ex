defmodule GupAdmin.Resource.Publication do
  alias GupAdmin.Resource.Search

  def index_manager_base_url do
    System.get_env("GUP_INDEX_MANAGER_URL") || "http://localhost:4010"
  end

  # post to external site with httpoison
  def post_publication_to_gup(id, gup_user) do
    api_key = System.get_env("GUP_API_KEY")
    url = "#{gup_server_base_url()}/v1/drafts_admin?api_key=#{api_key}&username=#{gup_user}"
    pub = show_raw(id)
    body = %{"publication" => pub} |> Jason.encode!()
    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
  end

  def merge_publications(gup_id, publication_id, gup_user) do
    api_key = System.get_env("GUP_API_KEY")
    gup_id = gup_id |> String.split("_") |> List.last()
    merge_with_id = String.contains?(publication_id, "gup")
    |> case do
      true -> "&gup_id=" <> (String.split(publication_id, "_") |> List.last())
      _ -> ""
    end
    # set gup post in index as pending
    index_body = %{} |> Jason.encode!()
    api_key_index = System.get_env("GUP_INDEX_MANAGER_API_KEY")
    HTTPoison.put("#{index_manager_base_url()}/publications/pending/gup_#{gup_id}?api_key=#{api_key_index}", index_body, [{"Content-Type", "application/json"}])
    url =  "#{gup_server_base_url()}/v1/published_publications_admin/#{gup_id}?api_key=#{api_key}&username=#{gup_user}#{merge_with_id}"
    publication_identifiers = show_raw(publication_id)
    |> Map.get("publication_identifiers")
    body = %{"publication" => %{"publication_identifiers" => publication_identifiers}, "id" => gup_id} |> Jason.encode!()
    HTTPoison.put(url, body, [{"Content-Type", "application/json"}])
    {:ok, %{"message" => "Publication with id #{publication_id} merged with publication with id #{gup_id}"}}
  end

  def show(id) do
    Search.search_one(id) |> List.first()
    |> case do
      nil -> :error
      res -> return_res(res)
    end
  end

  def convert_authors(authors) do
    authors
    |> Enum.map(fn author ->
      person = author |> Map.get("person") |> List.first()
      ## FIXME: in WOS, the affiliation is called affilation, in scopus it is affiliations, fix this in the normalisation step
      affiliations = author |> Map.get("affiliations") || author |> Map.get("affilation")
      affiliation_list = case affiliations do
        nil -> []
        _ ->
          affiliations
          |> Enum.map(fn affiliation ->
            [
              affiliation |> Map.get("scopus-affilname"),
              affiliation |> Map.get("scopus-affiliation-city"),
              affiliation |> Map.get("scopus-affiliation-country")
            ]
            |> Enum.reject(&is_nil/1)
            |> Enum.join(", ")
          end)
      end
      %{
        "name" => get_author_name(person),
        "affiliations" => affiliation_list
      }
    end)
    # put array in a map with key data
    |> then(&%{"data" => &1})
  end

  def show_authors(id) do
    Search.search_one(id)
    |> List.first()
    |> case do
      nil -> :error
      res -> res |> Map.get("_source") |> Map.get("authors") |> convert_authors()
    end
  end

  def get_duplicates(params) do
    Search.get_duplicates(params)
    |> remap()
  end

  def mark_as_deleted(id) do
    Search.mark_as_deleted(id)
end

  def return_res(%{"_source" => %{"deleted" => true}}) do
    :error
  end

  def return_res(res) do
    pending = res |> Map.get("_source") |> Map.get("pending")
    res = res |> Map.get("_source") |> remap("new") |> clear_irrelevant_identifiers()

    %{
      "data" => res,
      "pending" => pending
    }
  end

  def show(id, :dont_clear_irrelevant_identifiers, missing_status) do
    res = Search.search_one(id)
    res
    |> length()
    |> case do
      0 -> %{"statusMessage" => "Post not found", "statusCode" => missing_status}
      _ -> {:ok, res |> List.first() |> Map.get("_source") |> remap("new")}
    end
  end

  def show_raw(id) do
    Search.search_one(id)
    |> List.first()
    |> case do
      nil -> :error
      hits -> hits |> Map.get("_source")
    end
  end



  def remap({hits, total}) do
    hits = hits
    |> Enum.map(fn hit -> hit["_source"] end)
    |> remap_authors()
    data = Enum.take(hits, 50)
    showing = length(data)
    %{
      "total" => total,
      "data" => data,
      "showing" => showing
    }
  end


  def remap(hits) do
    remap({hits, 0})
  end

  def remap_authors(data) do
    data
    |> Enum.map(fn publication ->
        publication |> Map.put("authors", publication |> has_authors() |> Map.get("authors") |> Enum.map(fn author -> author |> extract_author() end))
    end)
  end

  def has_authors(publication) do
    case publication["authors"] do
      nil -> Map.put(publication, "authors", [])
      _ -> publication
    end
  end

  def extract_author(author) do

    person = author
    |> Map.get("person")
    |> List.first()

    id = Map.get(person, "id")
    %{
      "name" => get_author_name(person),
      "id" => id
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
    with {:ok, post_1} <- show(id_1, :dont_clear_irrelevant_identifiers, "404"),
      {:ok, post_2} <- show(id_2, :dont_clear_irrelevant_identifiers, "200")
    do
      data = post_1
      |> Enum.with_index()
      |> Enum.map(fn {first, index} ->
        second = Enum.at(post_2, index)
        {compare_data_1, compare_data_2} = {transform_compare_data(first), transform_compare_data(second)}
        first
        |> Map.put("second", second["first"])
        |> Map.put("diff", compare(compare_data_1, compare_data_2))
      end)
      |> clear_irrelevant_identifiers()
      {:ok, %{"data" => data}}
    else
      err ->  {:error, err}
    end
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

  def compare(%{"display_type" => "meta"} = _first, %{"display_type" => "meta"} = _second), do: false
  def compare(%{"display_type" => "title"} = _first, %{"display_type" => "title"} = _second), do: false
  def compare(first, second), do: !(first === second)

  def transform_compare_data(data) when is_bitstring(data) do
    data |> String.downcase()
  end

  def transform_compare_data(data) when is_map(data) do
    data
    |> Enum.map(fn {k, v} -> {k, transform_compare_data(v)} end)
    |> Map.new()
  end

  def transform_compare_data(data) when is_list(data) do
    data
    |> Enum.map(fn item -> transform_compare_data(item) end)
  end

  def transform_compare_data(data) do
    data
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

  def get_author_block(author) do
    person = Map.get(author, "person")
    case length(person) do
      0 -> %{
        "id" => nil,
        "name" => "",
        "x-account" => ""
      }
      _ -> %{
        "name" => get_author_name(person |> List.first())
      }
    end
  end

  def get_author_name(author) do
    last_name = author["last_name"] || ""
    first_name = author["first_name"] || ""
    first_name <> " " <> last_name
  end

  def get_authors(data) do
    data["authors"]
    |> case  do
      nil -> []
      authors -> authors
    end
    |> sort_authors()
    |> Enum.map(fn author -> get_author_block(author) end)
  end

  def sort_authors([]) do
    []
  end

  def sort_authors(authors) do
    authors
    |> IO.inspect()
    |> List.first()
    |> Map.has_key?("position")
    |> case do
      true -> Enum.sort_by(authors, fn author -> author["position"] |> List.first() |> Map.get("position") end)
      _ -> authors
    end
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
      "handle" -> "https://hdl.handle.net/#{value}"
      "libris-id" -> "https://libris.kb.se/bib/#{value}"
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

  def gup_server_base_url() do
    System.get_env("GUP_SERVER_BASE_URL", "http://localhost:40191")
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
