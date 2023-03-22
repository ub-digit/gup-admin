defmodule Experiment do
  @index "publications"

  def elastic_url do
    System.get_env("ELASTIC_SEARCH_URL") || "http://localhost:9200"
  end


  def create_index(name) do
    config = %{
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
            "analyzer" => "edge_ngram_analyzer",
            "search_analyzer" => "standard"
          }
        }
      },
      "settings" => %{
        "analysis" => %{
          "analyzer" => %{
            "edge_ngram_analyzer" => %{
              "tokenizer" => "edge_ngram_tokenizer",
              "filter" => [
                "lowercase"
              ]
            }
          },
          "tokenizer" => %{
            "edge_ngram_tokenizer" => %{
              "type" => "edge_ngram",
              "min_gram" => 2,
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
          }
        }
      }
    }

    Elastix.Index.delete(elastic_url(), name)

    Elastix.Index.create(elastic_url(), name, config)
    |> case do
      {:ok, %{body: %{"error" => reason}}} -> {:error, reason}
      {:ok, res} -> {:ok, res}
    end
  end



  # Function that returns a list of filenames from a directory
  def get_file_names(count \\ 20) do
    File.ls!("../data/_source")
    |> Enum.take(count)
  end

  def init_with_json(count \\ 20) do
    get_file_names(count)
    # read all files in list
    |> Enum.map(fn file -> File.read!("../data/_source/" <> file) end)
    # parse json
    |> Enum.map(fn json -> Jason.decode!(json) end)
    # remap fields
    |> Enum.map(fn item -> remap_fields(item) end)
   # |> gupify_data()
    |> mockup_data(count)
  end

  def init(publications_count \\ 500) do
    create_index(@index)
    init_with_json(publications_count)
    |> Enum.map(fn data ->
      Elastix.Document.index(elastic_url(), "publications", "_doc", data["id"], data, [])
    end)

  end

  def gupify_data(data) do
    data
    |> Enum.map(fn item ->
      item
      |> Map.put("id", "gup:" <> Integer.to_string(item["id"]))
      |> Map.put("source", "gup")
    end)
  end

  def mockup_data(data, count) do
    split_count = floor(count / 2)
    {gup, scopus} = Enum.split(data, split_count)
    scopus = scopus
    #generate mockup new scopus publications
    |> Enum.map(fn item ->
      item
      |> Map.put("id", "scopus:" <> Integer.to_string(item["id"] + 10000))
      |> Map.put("source", "scopus")
      |> Map.put("title", Experiment.NameGen.generate())
    end)

    # generate duplicate scopus publications

    scopus_duplicates = Enum.take(gup, floor(split_count / 4))
    |> Enum.map(fn item ->
      item
      |> Map.put("id", "scopus:" <> Integer.to_string(item["id"]))
      |> Map.put("source", "scopus")
    end)

    # Add source and id to gup publications
    gup = gup
    |> Enum.map(fn item ->
      item
      |> Map.put("id", "gup:" <> Integer.to_string(item["id"]))
      |> Map.put("source", "gup")
    end)


    [gup, scopus, scopus_duplicates]
    |> List.flatten()
    # |> Enum.map(fn item ->
    #   %{"title" => item["title"],
    #   "source" => item["source"],
    #   "id" => item["id"],
    # }
    # |> IO.inspect()
    #end)
  end

  def generate_scopus_data(data) do
    data
    |> Enum.map(fn item ->
      item
      |> Map.put("id", "scopus:" <> Integer.to_string(item["id"] + 10000))
      |> Map.put("source", "scopus")
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


  def db_txt() do
    "  1 | conference_other
    2 | conference_paper
    3 | conference_poster
    5 | publication_journal-article
    7 | publication_magazine-article
    8 | publication_edited-book
    9 | publication_book
   10 | publication_book-chapter
   13 | intellectual-property_patent
   16 | publication_report
   17 | publication_doctoral-thesis
   18 | publication_book-review
   19 | publication_licentiate-thesis
   21 | other
   22 | publication_review-article
   23 | artistic-work_scientific_and_development
   28 | publication_textcritical-edition
   30 | publication_textbook
   34 | artistic-work_original-creative-work
   40 | publication_editorial-letter
   41 | publication_report-chapter
   42 | publication_newspaper-article
   43 | publication_encyclopedia-entry
   44 | publication_journal-issue
   45 | conference_proceeding
   46 | publication_working-paper"
  |> String.split("\n")
  |> Enum.map(fn line ->
    %{
      "publications_type_id" => line |> String.split("|") |> List.first() |> String.trim() |> String.to_integer(),
      "publications_type_label" => line |> String.split("|") |> List.last() |> String.trim()
    }
    end)
  end

end
