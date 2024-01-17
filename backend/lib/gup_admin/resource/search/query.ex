defmodule GupAdmin.Resource.Search.Query do
  @query_limit 1000
  def base(term) do
    %{
      "track_total_hits" => true,
      "size" => @query_limit,
      "sort" => [
        %{
          "updated_at" => %{
            "order" => "desc"  # "asc" for ascending order, "desc" for descending order
          }
        }
      ],
      "query" => %{
        "bool" => %{
        "must" => get_query_type(escape_characters(term))
        }
      }
    }
  end

  def get_query_type("") do
    [
      %{
        "match_all" => %{}
      }
    ]
  end

  def get_query_type(term) do
    %{
      "query_string" => %{
        "default_operator" => "AND",
        "fields" => ["title^15", "id", "origin_id", "publication_identifiers.identifier_value"],
        "query" => term
      }
    }
  end
  def find_duplicates_by_identifiers([]), do: nil
  def find_duplicates_by_identifiers(identifiers) do
    %{
      "query" => %{
        "bool" => %{
          "should" => identifier_blocks(identifiers)
        }
      }
    }
  end

  def identifier_blocks(identifiers) do
    Enum.reduce(identifiers, [], fn identifier, acc ->
      acc ++ [
        %{
          "bool" => %{
            "must" => [
              %{
                "query_string" => %{
                  "fields" => ["publication_identifiers.identifier_value.keyword"],
                  "query" => "\"" <> identifier["identifier_value"] <> "\"" #escape_characters(identifier["identifier_value"]),
                }
              },
              %{
                "query_string" => %{
                  "fields" => ["publication_identifiers.identifier_code"],
                  "query" => identifier["identifier_code"]
                }
              },
              %{
                "term" => %{
                  "deleted" => false
                }
              }
            ]
          }
        }
      ]
    end)
  end

  def fuzzy(term) do
    %{
      "query" => %{
        "bool" => %{
          "must" => [
            %{
              "match" => %{
                "title" => %{
                  "fuzziness" => "AUTO",
                  "query" => term
                }
              }
            },
            %{
              "term" => %{
                "deleted" => false
              }
            }
          ]
        }
      }
    }
  end

  def show_base(id) do
    %{
      "size" => @query_limit,
      "query" => %{
        "bool" => %{
          "must" => %{
            "match" => %{
              "id" => id
            }
          }
        }
      }
    }
  end

  def escape_characters(term) do
    term
    |> String.replace("/", "\\/")
    |> String.replace("(", "\\(")
    |> String.replace(")", "\\)")
  end
end
