defmodule Experiment do
  @elastic_url "http://localhost:9200"
  def data do
    [
      %{
        id: 1,
        authors: ["John Smith"],
        title: "Lorem Ipsum",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        publication_type: "Doktorsavhandling",
        publication_date: "2001-05-01",
        source: "wos"
      },
      %{
        id: 2,
        authors: ["Jane Doe"],
        title: "Dolor Sit Amet",
        description:
          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        publication_type: "Rapport",
        publication_date: "2002-03-15",
        source: "scopus"
      },
      %{
        id: 3,
        authors: ["Bob Johnson"],
        title: "Consectetur Adipiscing",
        description:
          "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publication_type: "Konstnärligt arbete",
        publication_date: "2003-09-23",
        source: "wos"
      },
      %{
        id: 4,
        authors: ["Alice Williams", "Tom Brown"],
        title: "Vestibulum Mattis",
        description:
          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        publication_type: "Artikel i vetenskaplig tidskrift",
        publication_date: "2004-06-30",
        source: "scopus"
      },
      %{
        id: 5,
        authors: ["Samantha Lee"],
        title: "Mauris Auctor",
        description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        publication_type: "Patent",
        publication_date: "2005-11-17",
        source: "wos"
      },
      %{
        id: 6,
        authors: ["Mark Jones"],
        title: "Phasellus Ultrices",
        description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        publication_type: "Artikel i vetenskaplig tidskrift",
        publication_date: "2010-08-01",
        source: "scopus"
      },
      %{
        id: 7,
        authors: ["Emily Davis", "David Brown"],
        title: "Pellentesque Euismod",
        description:
          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        publication_type: "Doktorsavhandling",
        publication_date: "2014-07-22",
        source: "wos"
      },
      %{
        id: 8,
        authors: ["Alexandra Johnson"],
        title: "Sed Dignissim",
        description:
          "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publication_type: "Rapport",
        publication_date: "2017-01-09",
        source: "scopus"
      },
      %{
        id: 9,
        authors: ["Chris Lee"],
        title: "Aenean Mattis",
        description:
          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        publication_type: "Konstnärligt arbete",
        publication_date: "2019-11-30",
        source: "wos"
      },
      %{
        id: 10,
        authors: ["Sarah Taylor"],
        title: "Fusce Ornare",
        description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        publication_type: "Artikel i vetenskaplig tidskrift",
        publication_date: "2022-02-14",
        source: "scopus"
      }
    ]
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
                "digit"
              ]
            }
          }
        }
      }
    }

    Elastix.Index.delete(@elastic_url, name)

    Elastix.Index.create(@elastic_url, name, config)
    |> case do
      {:ok, %{body: %{"error" => reason}}} -> {:error, reason}
      {:ok, res} -> {:ok, res}
    end
  end

  def init do
    create_index("publications")

    data()
    |> Enum.map(fn data ->
      Elastix.Document.index(@elastic_url, "publications", "_doc", data.id, data, [])
    end)
  end
end
