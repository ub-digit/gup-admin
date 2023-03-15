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
    data_set()
    |> Enum.map(fn data ->
      Elastix.Document.index(@elastic_url, "publications", "_doc", data["id"], data, [])
    end)
  end

  def data_set do
    [
      %{
        "id" => "1",
        "title" => "The X Factor",
        "doi" => "http://doi.org/10.2",
        "creator" => "1johndoe",
        "authors" => [
          %{
            "id" => "1",
            "name" => "Alex Smith",
            "x-account" => "1alexsmith"
          }
        ],
        "gup_id" => "1",
        "scopus_id" => "1",
        "date" => "1999",
        "pubtype" => "11",
        "number_of_authors" => 1
      },
      %{
        "id" => "2",
        "title" => "The X-Files",
        "doi" => "http://doi.org/10.2",
        "creator" => "2johndoe",
        "authors" => [
          %{
            "id" => "2",
            "name" => "Brianna Lee",
            "x-account" => "2briannalee"
          }
        ],
        "gup_id" => "2",
        "scopus_id" => "2",
        "date" => "2008",
        "pubtype" => "10",
        "number_of_authors" => 1
      },
      %{
        "id" => "3",
        "title" => "X Marks the Spot",
        "doi" => "http://doi.org/10.2",
        "creator" => "3johndoe",
        "authors" => [
          %{
            "id" => "3",
            "name" => "Caroline Kim",
            "x-account" => "3carolinekim"
          }
        ],
        "gup_id" => "3",
        "scopus_id" => "3",
        "date" => "2015",
        "pubtype" => "22",
        "number_of_authors" => 1
      },
      %{
        "id" => "4",
        "title" => "The X-Men",
        "doi" => "http://doi.org/10.2",
        "creator" => "4johndoe",
        "authors" => [
          %{
            "id" => "4",
            "name" => "David Rodriguez",
            "x-account" => "4davidrodriguez"
          }
        ],
        "gup_id" => "4",
        "wos_id" => "4",
        "date" => "2006",
        "pubtype" => "18",
        "number_of_authors" => 1
      },
      %{
        "id" => "5",
        "title" => "The X-periment: Part I",
        "doi" => "http://doi.org/10.2",
        "creator" => "5johndoe",
        "authors" => [
          %{
            "id" => "5",
            "name" => "Elizabeth Taylor",
            "x-account" => "5elizabethtaylor"
          }
        ],
        "gup_id" => "5",
        "wos_id" => "5",
        "date" => "1988",
        "pubtype" => "9",
        "number_of_authors" => 1
      },
      %{
        "id" => "6",
        "title" => "X-Treme Sports",
        "doi" => "http://doi.org/10.2",
        "creator" => "6johndoe",
        "authors" => [
          %{
            "id" => "6",
            "name" => "Franklin Lee",
            "x-account" => "6franklinlee"
          }
        ],
        "gup_id" => "6",
        "scopus_id" => "6",
        "date" => "1995",
        "pubtype" => "3",
        "number_of_authors" => 1
      },
      %{
        "id" => "7",
        "title" => "X-Ray Vision",
        "doi" => "http://doi.org/10.2",
        "creator" => "7johndoe",
        "authors" => [
          %{
            "id" => "7",
            "name" => "Grace Kim",
            "x-account" => "7gracekim"
          }
        ],
        "gup_id" => "7",
        "scopus_id" => "7",
        "date" => "2003",
        "pubtype" => "12",
        "number_of_authors" => 1
      },
      %{
        "id" => "8",
        "title" => "Xylophone Adventures",
        "doi" => "http://doi.org/10.2",
        "creator" => "8johndoe",
        "authors" => [
          %{
            "id" => "8",
            "name" => "Hannah Nguyen",
            "x-account" => "8hannahnguyen"
          }
        ],
        "gup_id" => "8",
        "scopus_id" => "8",
        "date" => "2017",
        "pubtype" => "4",
        "number_of_authors" => 1
      },
      %{
        "id" => "9",
        "title" => "The X-perience",
        "doi" => "http://doi.org/10.2",
        "creator" => "9johndoe",
        "authors" => [
          %{
            "id" => "9",
            "name" => "Ivy Johnson",
            "x-account" => "9ivyjohnson"
          }
        ],
        "gup_id" => "9",
        "wos_id" => "9",
        "date" => "2019",
        "pubtype" => "14",
        "number_of_authors" => 1
      },
      %{
        "id" => "10",
        "title" => "The X-Factor: A Guide to Success",
        "doi" => "http://doi.org/10.2",
        "creator" => "10johndoe",
        "authors" => [
          %{
            "id" => "10",
            "name" => "Jacob Lee",
            "x-account" => "10jacoblee"
          }
        ],
        "gup_id" => "10",
        "wos_id" => "10",
        "date" => "2022",
        "pubtype" => "23",
        "number_of_authors" => 1
      },
      %{
        "id" => "20",
        "title" => "The Power of Networking",
        "doi" => "http://doi.org/10.3",
        "creator" => "20janedoe",
        "authors" => [
          %{
            "id" => "20",
            "name" => "Emily Chang",
            "x-account" => "20emilychang"
          }
        ],
        "gup_id" => "20",
        "date" => "2021",
        "pubtype" => "18",
        "number_of_authors" => 1,
        "source" => "manual"
      },
      %{
        "id" => "21",
        "title" => "Leadership in the Digital Age",
        "doi" => "http://doi.org/10.4",
        "creator" => "21johndoe",
        "authors" => [
          %{
            "id" => "21",
            "name" => "Olivia Chen",
            "x-account" => "21oliviachen"
          }
        ],
        "gup_id" => "21",
        "date" => "2023",
        "pubtype" => "14",
        "number_of_authors" => 1,
        "source" => "manual"
      },
      %{
        "id" => "22",
        "title" => "Navigating the Gig Economy",
        "doi" => "http://doi.org/10.5",
        "creator" => "22johndoe",
        "authors" => [
          %{
            "id" => "22",
            "name" => "Sophia Rodriguez",
            "x-account" => "22sophiarodriguez"
          }
        ],
        "gup_id" => "22",
        "date" => "2020",
        "pubtype" => "11",
        "number_of_authors" => 1,
        "source" => "manual"
      },
      %{
        "id" => "23",
        "title" => "The Art of Negotiation",
        "doi" => "http://doi.org/10.6",
        "creator" => "23johndoe",
        "authors" => [
          %{
            "id" => "23",
            "name" => "Isabella Kim",
            "x-account" => "23isabellakim"
          }
        ],
        "gup_id" => "23",
        "date" => "2019",
        "pubtype" => "19",
        "number_of_authors" => 1,
        "source" => "manual"
      },
      %{
        "id" => "24",
        "title" => "Innovative Marketing Strategies",
        "doi" => "http://doi.org/10.7",
        "creator" => "24johndoe",
        "authors" => [
          %{
            "id" => "24",
            "name" => "Ethan Lee",
            "x-account" => "24ethanlee"
          }
        ],
        "gup_id" => "24",
        "date" => "2022",
        "pubtype" => "12",
        "number_of_authors" => 1,
        "source" => "manual"
      }
    ]
    |> Enum.map(fn item -> set_source(item) end)
  end

  def set_source(%{"source" => _} = item), do: item
  def set_source(item) do
    case Map.has_key?(item, "wos_id") do
      true -> Map.put(item, "source", "wos")
      false -> Map.put(item, "source", "scopus")
    end
  end
end
