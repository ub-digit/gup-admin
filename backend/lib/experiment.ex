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
      id = item["id"]
      item
      |> Map.put("id", "scopus:" <> Integer.to_string(id))
      |> Map.put("source", "scopus")
      |> put_in(["publication_identifiers"], %{"id" => id, "identifier_code" => "gup", "identifier_value" => id, "identifier_label" => "GUP"})
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
    "30 | publication_textbook                     | Lärobok
    28 | publication_textcritical-edition         | Textkritisk utgåva
    21 | other                                    | Annan publikation
    17 | publication_doctoral-thesis              | Doktorsavhandling
    16 | publication_report                       | Rapport
     2 | conference_paper                         | Paper i proceeding
     1 | conference_other                         | Konferensbidrag (offentliggjort, men ej förlagsutgivet)
     8 | publication_edited-book                  | Samlingsverk (red.)
    41 | publication_report-chapter               | Kapitel i rapport
    42 | publication_newspaper-article            | Artikel i dagstidning
    43 | publication_encyclopedia-entry           | Bidrag till encyklopedi
    19 | publication_licentiate-thesis            | Licentiatsavhandling
    44 | publication_journal-issue                | Special / temanummer av tidskrift (red.)
     3 | conference_poster                        | Poster (konferens)
    45 | conference_proceeding                    | Proceeding (red.)
    13 | intellectual-property_patent             | Patent
    23 | artistic-work_scientific_and_development | Konstnärligt forsknings- och utvecklingsarbete
    10 | publication_book-chapter                 | Kapitel i bok
    22 | publication_review-article               | Forskningsöversiktsartikel (Review article)
     5 | publication_journal-article              | Artikel i vetenskaplig tidskrift
    40 | publication_editorial-letter             | Inledande text i tidskrift
    18 | publication_book-review                  | Recension
     7 | publication_magazine-article             | Artikel i övriga tidskrifter
     9 | publication_book                         | Bok
    46 | publication_working-paper                | Working paper
    34 | artistic-work_original-creative-work     | Konstnärligt arbete"
  |> String.split("\n")
  |> Enum.map(fn line ->
     line = line |> String.split("|") |> List.to_tuple()

    %{
      "publication_type_id" => elem(line, 0) |> String.trim() |> String.to_integer(),
      "publication_type_code" => elem(line, 1) |> String.trim(),
      "publication_type_label" => elem(line, 2) |> String.trim()
    }
    end)
    |> Enum.sort_by(fn pub_type -> pub_type["publication_type_label"] end)
  end

end
