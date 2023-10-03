defmodule Experiment do
  @index "publications"

  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL", "http://localhost:9200")
  end

  def index_manager_url do
    System.get_env("GUP_INDEX_MANAGER_URL", "http://localhost:4010")
  end

  # Function that returns a list of filenames from a directory
  def get_gup_file_names() do
    File.ls!("../data/_source")
    |> Enum.reject(fn file -> file == ".gitignore" end)
  end

  def load_gup_data(count \\ 1_000_000) do
    get_gup_file_names()
    |> Enum.take(count)
    # read all files in list
    |> Enum.map(fn file -> File.read!("../data/_source/" <> file) end)
    # parse json
    |> Enum.map(fn json -> Jason.decode!(json) end)
    # remap fields
    |> Enum.map(fn item -> remap_fields(item) end)
    |> Enum.map(fn item -> Map.put(item, "source", "gup") end)
    |> Enum.map(fn item -> Map.put(item, "id", "gup_" <> Integer.to_string(item["id"])) end)
  end

  def append_list(a, b) do
    a ++ b
  end


  def init(count \\ 1_000_000) do
    #create_index(@index)
    load_gup_data(count)
    |> append_list(load_scopus_data(count))
    |> Enum.map(fn post -> Map.put(post, "deleted", false) end)
    # |> Enum.map(fn post -> Map.put(post, "attended", false) end)

    #|> Enum.map(fn data -> %{"title" => data["title"], "id" => data["id"], "attended" => data["attended"], "deleted" => data["deleted"], "source" => data["source"], "pubyear" => data["pubyear"]} end)
    #|> Enum.map(fn data -> %{"title" => data["title"], "id" => data["id"]} end)
    |> Enum.map(fn data ->
      data
      |> auto_put()
    end)
    %{"status" => "index ok"}
  end


  ########################################################
  # Functions for remapping fields                      #
  ########################################################

  def remap_fields(publication) do
    publication
    |> Map.put("authors", strip_authors(publication["authors"]))
  end


  def strip_authors([]), do: []
  def strip_authors(nil), do: []
  def strip_authors(authors) do
    authors
    |> Enum.map(fn author ->
      %{
        "id" => author["id"],
        "name" => get_full_name(author["first_name"], author["last_name"]),
        "x-account" => get_x_account(author["identifiers"]),
        "departments" => get_departments(author["departments"])
      }
    end)
  end

  def get_full_name(nil, nil), do: ""
  def get_full_name(nil, last_name), do: last_name
  def get_full_name(first_name, nil), do: first_name
  def get_full_name(first_name, last_name), do: first_name <> " " <> last_name



  def get_x_account([]), do: nil

  def get_x_account(identifiers) do
    identifiers
    |> Enum.find(fn identifier -> identifier["source_name"] == "xkonto" end)
    |> case do
      nil -> ""
      map -> Map.get(map, "value")
    end
  end

  def get_departments([]), do: nil
  def get_departments(department) do
   %{
      "id" => department["id"],
      "name" => department["name"],
      "faculty" => get_faculty(department["faculty"]),
   }
  end

  def get_faculty(faculty) do
    %{
      "id" => faculty["id"],
      "name" => faculty["name"]
    }
  end
  def benchmark(name, fun, args) do
    start = System.monotonic_time(:millisecond)
    fun.(args)
    finish = System.monotonic_time(:millisecond)
    IO.puts("#{name} took #{finish - start} ms")
  end

  def get_publication_type_list(publications) do
    publications
    |> Enum.map(fn publication ->
      %{
        "publications_type_id" => publication["publication_type_id"],
        "publications_type_label" => publication["publication_type_label"]
      }
      end)
    |> Enum.uniq()
    |> Enum.sort_by(fn pub_type -> pub_type["publications_type_id"] end)
  end






    def config do

      %{
        "settings" => %{
          "analysis" => %{
            "filter" => %{
              "autocomplete_filter" => %{
                "type" => "edge_ngram",
                "min_gram" => 1,
                "max_gram" => 20,
                "token_chars" => [
                              "letter",
                              "digit",
                              "custom"
                            ], "custom_token_chars" => [
                              "å",
                              "ä",
                              "ö",
                              "Å",
                              "Ä",
                              "Ö",
                              "-"
                            ]
              }
            },
            "analyzer" => %{
              "autocomplete" => %{
                "type" => "custom",
                "tokenizer" => "standard",
                "filter" => [
                  "lowercase",
                  "autocomplete_filter"
                ]
              }
            }
          }
        },
        "mappings" => %{
          "properties" => %{
            "title" => %{
               "fields" => %{
                 "sort" => %{
                  "type" => "icu_collation_keyword",
                  "language" => "sv",
                  "country" => "SE"
                }
              },
              "type" => "text",
              "analyzer" => "autocomplete",
              "search_analyzer" => "standard"
            },
            "id" => %{
              "type" => "keyword"
            }
          }
        }
      }

    end




    def load_scopus_data(count \\ 1_000_000) do
      get_scopus_file_list()
      |> Enum.take(count)
      |> Enum.map(fn file ->
        File.read!(file)
        |> Jason.decode!()
      end)
      |> Enum.map(&set_scopus_id/1)
      |> Enum.map(fn item -> Map.put(item, "source", "scopus")end)
    end

    def set_scopus_id(post) do
      id = Map.get(post, "publication_identifiers")
      |> Enum.find(fn identifier -> identifier["identifier_code"] == "scopus-id" end)
      |> Map.get("identifier_value")
      Map.put(post, "id", "scopus_" <> id)
    end

    def get_scopus_file_list do
      File.ls!("../data/scopus-normalised/")
      |> Enum.reject(fn dir -> dir == ".gitignore" end)
      |> List.flatten()
      |> Enum.map(fn dir -> Path.join("../data/scopus-normalised/", dir) end)
      |> Enum.map(fn dir ->
        File.ls!(dir)
        |> Enum.map(fn file -> Path.join(dir, file) end)
      end)
      |> List.flatten()
    end

    def compare(first, second) do
      case first === second do
        true -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", false)
        false -> Map.put(first, "second", Map.get(second, "first")) |> Map.put("diff", true)
      end
    end

    def merge_rules(key, val1, val2) do
      IO.inspect(val1 == val2, label: "#{key}")
      val1
    end

    def auto_put(data) do
      base_url = index_manager_url()
      api_key = System.get_env("GUP_INDEX_MANAGER_API_KEY", "megasecretimpossibletoguesskey")
      url = "#{base_url}/publications?api_key=#{api_key}"
      %{"url" => url}
      body = %{"data" => data} |> Jason.encode!()
      HTTPoison.put(url, body, [{"Content-Type", "application/json"}])
    end

    def check_env(var_name) do
      System.get_env(var_name)
      |> IO.inspect(label: "#{var_name} value")
    end

    def find_libris do
      load_gup_data()
      |> Enum.filter(fn post ->
        post
        |> Map.get("publication_identifiers")
        |> Enum.any?(fn identifier -> identifier["identifier_code"] == "libris-id" end)
      end)
      |> Enum.map(fn d -> Map.get(d, "id") end)
      |> IO.inspect()
    end

    def sort_on_date_updated(data) do
      data
      |> Enum.map(fn i -> i |> Map.put("updated_at_real_date", (DateTime.from_iso8601((i |> Map.get("updated_at")) <> "Z"  ))) end)
      |> Enum.sort_by(fn post -> post["updated_at_real_date"] end)
      |> Enum.map(fn i -> Map.delete(i, "updated_at_real_date") end)
      |> Enum.reverse()
      #|> Enum,map(fn item -> Map.put(item, "updated_at_real_date", DateTime.from_iso8601(Item["updated_at"] <> "Z")) end)
      #|> Enum.sort_by(fn post -> post["updated_at_real_date"] end)
      #|> Enum.map(fn i -> Map.delete(i, "updated_at_real_date") end)
      #|> Enum.reverse()
    end

  end
