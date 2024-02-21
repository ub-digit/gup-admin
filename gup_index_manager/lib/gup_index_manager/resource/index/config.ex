defmodule GupIndexManager.Resource.Index.Config do
  @max_gram 20
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
              ],
              "custom_token_chars" => [
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
            },
            "custom_lowercase_analyzer" => %{
              "tokenizer" => "keyword",
              "filter" => ["lowercase"]
            }
          }
        }
      },
      "mappings" => %{
        "properties" => %{
            "publication_identifiers" => %{
              "properties" => %{
                "identifier_value" => %{
                  "type" => "text",
                  "analyzer" => "custom_lowercase_analyzer",
                  "fields" => %{
                    "keyword" => %{
                      "type" => "keyword",
                      "ignore_above" => 256
                    }
                  }
                }
              }
            },

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

  def departments_config do
    %{
      "settings" => %{
        "analysis" => %{
          "filter" => %{
            "autocomplete_filter" => %{
              "type" => "edge_ngram",
              "min_gram" => 2,
              "max_gram" => @max_gram,
              "token_chars" => [
                "letter",
                "digit",
                "custom"
              ],
              "custom_token_chars" => [
                "å",
                "ä",
                "ö",
                "Å",
                "Ä",
                "Ö",
                "-"
              ]
            },
            "truncate_filter" => %{
              "type" => "truncate",
              "length" => @max_gram
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
            },
            "standard_truncate" => %{
              "type" => "custom",
              "tokenizer" => "standard",
              "filter" => [
                "lowercase",
                "truncate_filter"
              ]
            }
          }
        }
      },
      "mappings" => %{
        "properties" => %{
          "name" => %{
            "fields" => %{
              "sort" => %{
                "type" => "icu_collation_keyword",
                "language" => "sv",
                "country" => "SE"
              }
            },
            "type" => "text",
            "analyzer" => "autocomplete",
            "search_analyzer" => "standard_truncate"

          }
        }
      }
    }

  end
end
