defmodule GupAdmin.Resource.Publication do
  alias GupAdmin.Resource.Search
  # post to external site with httpoison
  def post_publication_to_gup(id) do
    user = System.get_env("GUP_USER", nil)
    |> case do
      nil -> raise "GUP_USER not set"
      user -> user
    end

    api_key = System.get_env("GUP_API_KEY", "an-api-key")
    url = "https://gup-server-lab.ub.gu.se/v1/drafts_admin?api_key=#{api_key}&username=#{user}"
    pub = show(id)
    body = %{"publication" => pub} |> Jason.encode!()
    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
  end

  def show(id) do
    Search.search_one(id)
    |> List.first()
    |> Map.get("_source")
    |> remap("new")
    # |> case do
    #   nil -> :error
    #   res -> res
    # end
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
    |> get_row("first", :string, "publication_id", get_publication_id(data))
    |> get_row("first", :string, "id", data["id"])
    |> get_row("first", :title, "title", data["title"], get_publication_url(data))
    |> get_row("first", :meta, data)
    |> get_row("first", :string, "publication_type_label", data["publication_type_label"])
    |> get_row("first", :string, "sourcetitle", data["sourcetitle"])
    |> get_row("first", :string, "pubyear", data["pubyear"])
    |> get_row("first", :sourceissue_sourcepages_sourcevolume, "sourceissue_sourcepages_sourcevolume", data)
    |> get_row("first", :authors, "authors", data)
    |> get_publication_identifier_rows("first", data)
  end

  def compare_posts(id_1, id_2) do
    post_1 = show(id_1)
    post_2 = show(id_2)
    IO.inspect(post_2, label: "post_2 length")
    # post_1
    # |> Enum.with_index()
    # |> Enum.map(fn {first, index} ->
    #   compare(first, Enum.at(post_2, index))
    # end)
  end

  def compare(first, second) do
    #IO.inspect(is_map(second), label: "sec is_map")
    # case first === second do
    #   true -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", false)
    #   false -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", true)
    # end
  end

  def get_row(container, order, :string, display_label, value) do
    container ++
    [
      %{
        order => %{
          "value" => value || "missing",
        },
        "display_label" => display_label,
        "display_type" => "string",
        "visibility" => get_visibility(display_label)
      }
    ]
  end

  def get_row(container, order, :sourceissue_sourcepages_sourcevolume, display_label, data) do
    container ++
    [
      %{
        order => %{
          "value" => %{
            "sourcevolume" => data["sourcevolume"] || "missing",
            "sourceissue" => data["sourceissue"] || "missing",
            "sourcepages" => data["sourcepages"] || "missing"
          }
        },
        "display_label" => display_label,
        "display_type" => "sourceissue_sourcepages_sourcevolume",
        "visibility" => get_visibility(display_label)
      }
    ]
  end

  def get_row(container, order, :authors, display_label, data) do
    container ++
    [
      %{
        order => %{
          "value" => get_authors(data)
        },
        "display_label" => display_label,
        "display_type" => "authors",
        "visibility" => get_visibility(display_label)
      }
    ]
  end

  def get_row(container, order, :title, display_label, value, url) do
    container ++
    [
      %{
        order => %{
          "value" => %{
            "title" => value,
            "url" => url
          }
        },
        "display_label" => display_label,
        "display_type" => "title",
        "visibility" => get_visibility(display_label)
      }
    ]
  end

  def get_row(container, order, :meta, data) do
    container ++
    [
      %{
        order => %{
          "value" => %{
            "attended" => get_value_block(data["attended"], "attended"),
            "created_at" => get_value_block(data["created_at"], "created_at"),
            "version_created_by" => get_value_block(data["version_created_by"], "version_created_by"),
            "updated_at" => get_value_block(data["updated_at"], "updated_at"),
            "version_updated_by" => get_value_block(data["version_updated_by"], "version_updated_by"),
            "source" => get_value_block(data["source"], "source")
          }
        },
        "display_type" => "meta",
        "visibility" => get_visibility(:meta)
      }
    ]
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
        "visibility" => get_visibility("identifier")
      }]
    end)
  end

  def get_identifier_name_code(code) do
    case code do
      "doi" -> "doi"
      "scopus-id" -> "scopus"
      "isi-id" -> "isiid"
      "pubmed" -> "pubmed"
      _ -> "missing"
    end
  end

  def get_identifier_url(identifier) do
    identifier["identifier_code"]
    |> case do
      "doi" -> "https://dx.doi.org/#{identifier["identifier_value"]}"
      "scopus-id" -> "https://www.scopus.com/record/display.uri?eid=2-s2.0-#{identifier["identifier_value"]}&origin=resultslist"
      "isi-id" -> "https://www.webofscience.com/wos/woscc/full-record/WOS:#{["identifier_value"]}"
      _ -> "missing"
    end
  end

  def get_publication_url(data) do
    sys_id = data["id"]
    id = get_publication_id(data)
    case String.contains?(sys_id, "gup") do
      true -> gup_base_url() <> "/publications/show#{id}"
      _ -> ""
    end
  end

  def gup_base_url() do
    System.get_env("GUP_BASE_URL", "https://gup-staging.ub.gu.se")
  end

  def get_visibility(display_label) do
    case display_label do
      "title" -> "always"
      :meta -> "always"
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
