defmodule Experiment do
  @index "publications"

  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL") || "http://localhost:9200"
  end

  def index_manager_url do
    System.get_env("INDEX_MANAGER_URL") || "http://localhost:4010"
  end


  def create_index(name) do
    Elastix.Index.delete(elastic_url(), name)
    Elastix.Index.create(elastic_url(), name, config())
    |> case do
      {:ok, %{body: %{"error" => reason}}} -> {:error, reason}
      {:ok, res} -> {:ok, res}
    end
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
    create_index(@index)
    load_gup_data(count)
    |> append_list(load_scopus_data(count))
    |> Enum.map(fn post -> Map.put(post, "deleted", false) end)
    |> Enum.map(fn post -> Map.put(post, "attended", false) end)

    #|> Enum.map(fn data -> %{"title" => data["title"], "id" => data["id"], "attended" => data["attended"], "deleted" => data["deleted"], "source" => data["source"], "pubyear" => data["pubyear"]} end)
    #|> Enum.map(fn data -> %{"title" => data["title"], "id" => data["id"]} end)
    |> Enum.map(fn data ->
      data
      |> auto_put()
      #Elastix.Document.index(elastic_url(), "publications", "_doc", data["id"], data, [])
    end)

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

    def test_compare do
      a = [
        %{
          "display_label" => "publication_id",
          "display_type" => "string",
          "first" => %{"value" => "319647"},
          "visibility" => "never"
        },
        %{
          "display_label" => "id",
          "display_type" => "string",
          "first" => %{"value" => "gup_319647"},
          "visibility" => "never"
        },
        %{
          "display_label" => "title",
          "display_type" => "title",
          "first" => %{
            "value" => %{
              "title" => "Back to NO life: Is it possible to be myself again? A qualitative study with persons initially hospitalised due to COVID-19.",
              "url" => "https://gup-staging.ub.gu.se/publications/show319647"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_type" => "meta",
          "first" => %{
            "value" => %{
              "attended" => %{"display_label" => "attended", "value" => "false"},
              "created_at" => %{
                "display_label" => "created_at",
                "value" => "2022-11-01T10:44:39.429Z"
              },
              "source" => %{"display_label" => "source", "value" => "gup"},
              "updated_at" => %{
                "display_label" => "updated_at",
                "value" => "2022-11-01T10:46:28.983Z"
              },
              "version_created_by" => %{
                "display_label" => "version_created_by",
                "value" => "xtorka"
              },
              "version_updated_by" => %{
                "display_label" => "version_updated_by",
                "value" => "xtorka"
              }
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "publication_type_label",
          "display_type" => "string",
          "first" => %{"value" => "Artikel i vetenskaplig tidskrift"},
          "visibility" => "always"
        },
        %{
          "display_label" => "sourcetitle",
          "display_type" => "string",
          "first" => %{"value" => "Journal of rehabilitation medicine"},
          "visibility" => "always"
        },
        %{
          "display_label" => "pubyear",
          "display_type" => "string",
          "first" => %{"value" => 2022},
          "visibility" => "always"
        },
        %{
          "display_label" => "sourceissue_sourcepages_sourcevolume",
          "display_type" => "sourceissue_sourcepages_sourcevolume",
          "first" => %{
            "value" => %{
              "sourceissue" => "missing",
              "sourcepages" => "jrm00327",
              "sourcevolume" => "54"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "authors",
          "display_type" => "authors",
          "first" => %{
            "value" => [
              %{"id" => 209893, "name" => "Karin Törnbom", "x-account" => "xtorka"},
              %{"id" => 226669, "name" => "Marie Engwall", "x-account" => "xdmari"},
              %{"id" => 161292, "name" => "Hanna C Persson", "x-account" => "xperha"},
              %{"id" => 192711, "name" => "Annie Palstam", "x-account" => "xpanni"}
            ]
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "doi",
          "display_type" => "url",
          "first" => %{
            "value" => %{
              "display_title" => "10.2340/jrm.v54.2742",
              "url" => "https://dx.doi.org/10.2340/jrm.v54.2742"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "pubmed",
          "display_type" => "url",
          "first" => %{
            "value" => %{"display_title" => "35976766", "url" => "missing"}
          },
          "visibility" => "always"
        }
      ]

      b = [
        %{
          "display_label" => "publication_id",
          "display_type" => "string",
          "first" => %{"value" => "319647"},
          "visibility" => "never"
        },
        %{
          "display_label" => "id",
          "display_type" => "string",
          "first" => %{"value" => "gup_319647"},
          "visibility" => "never"
        },
        %{
          "display_label" => "title",
          "display_type" => "title",
          "first" => %{
            "value" => %{
              "title" => "Back to life: Is it possible to be myself again? A qualitative study with persons initially hospitalised due to COVID-19.",
              "url" => "https://gup-staging.ub.gu.se/publications/show319647"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_type" => "meta",
          "first" => %{
            "value" => %{
              "attended" => %{"display_label" => "attended", "value" => "false"},
              "created_at" => %{
                "display_label" => "created_at",
                "value" => "2022-11-01T10:44:39.429Z"
              },
              "source" => %{"display_label" => "source", "value" => "gup"},
              "updated_at" => %{
                "display_label" => "updated_at",
                "value" => "2022-11-01T10:46:28.983Z"
              },
              "version_created_by" => %{
                "display_label" => "version_created_by",
                "value" => "xtorka"
              },
              "version_updated_by" => %{
                "display_label" => "version_updated_by",
                "value" => "xtorka"
              }
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "publication_type_label",
          "display_type" => "string",
          "first" => %{"value" => "Artikel i vetenskaplig tidskrift"},
          "visibility" => "always"
        },
        %{
          "display_label" => "sourcetitle",
          "display_type" => "string",
          "first" => %{"value" => "Journal of rehabilitation medicine"},
          "visibility" => "always"
        },
        %{
          "display_label" => "pubyear",
          "display_type" => "string",
          "first" => %{"value" => 2022},
          "visibility" => "always"
        },
        %{
          "display_label" => "sourceissue_sourcepages_sourcevolume",
          "display_type" => "sourceissue_sourcepages_sourcevolume",
          "first" => %{
            "value" => %{
              "sourceissue" => "missing",
              "sourcepages" => "jrm00327",
              "sourcevolume" => "54"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "authors",
          "display_type" => "authors",
          "first" => %{
            "value" => [
              %{"id" => 209893, "name" => "Karin Törnbom", "x-account" => "xtorka"},
              %{"id" => 226669, "name" => "Marie Engwall", "x-account" => "xdmari"},
              %{"id" => 161292, "name" => "Hanna C Persson", "x-account" => "xperha"},
              %{"id" => 192711, "name" => "Annie Palstam", "x-account" => "xpanni"}
            ]
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "doi",
          "display_type" => "url",
          "first" => %{
            "value" => %{
              "display_title" => "10.2340/jrm.v54.2742",
              "url" => "https://dx.doi.org/10.2340/jrm.v54.2742"
            }
          },
          "visibility" => "always"
        },
        %{
          "display_label" => "pubmed",
          "display_type" => "url",
          "first" => %{
            "value" => %{"display_title" => "35976766", "url" => "missing"}
          },
          "visibility" => "always"
        }
      ]

      b = Enum.with_index(b)
      a
      |> Enum.with_index(fn first, index ->
        second = Enum.at(b, index) |> elem(0)
        compare(first, second)
      end)




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
      api_key = System.get_env("GUP_INDEX_MANAGER_API_KEY", "megasecretimpossibletoguesskey")
      url = "http://localhost:4010/publications?api_key=#{api_key}"
      body = %{"data" => data} |> Jason.encode!()
      HTTPoison.put(url, body, [{"Content-Type", "application/json"}])
    end
  end
