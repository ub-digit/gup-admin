defmodule GupIndexManager.Resource.Index.Config do
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
end
