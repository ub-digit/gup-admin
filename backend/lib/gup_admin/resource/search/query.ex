defmodule GupAdmin.Resource.Search.Query do
  @query_limit 1000
  def base(term) do
    %{
      "track_total_hits" => true,
      "size" => @query_limit,
      "sort" => [
        %{
          "updated_at" => %{
            # "asc" for ascending order, "desc" for descending order
            "order" => "desc"
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
          "should" => publication_identifier_blocks(identifiers)
        }
      }
    }
  end

  def publication_identifier_blocks(identifiers) do
    Enum.reduce(identifiers, [], fn identifier, acc ->
      acc ++
        [
          %{
            "bool" => %{
              "must" => [
                %{
                  "query_string" => %{
                    "fields" => ["publication_identifiers.identifier_value.keyword"],
                    # escape_characters(identifier["identifier_value"]),
                    "query" => "\"" <> identifier["identifier_value"] <> "\""
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

  def search_persons(q) do
    IO.inspect("search_persons query")
    # %{
    #   size: 100, #@query_limit,
    #   query: %{
    #     bool: %{
    #       must: %{
    #         query_string: %{
    #           default_operator: "AND",
    #           fields: ["names.first_name", "names.last_name", "names.full_name", "identifiers.value"],
    #           query: q
    #         }
    #       }
    #     }
    #   }
    # }
    # %{
    #   # @query_limit,
    #   size: 100,
    #   query: %{
    #     bool: %{
    #       must: %{
    #         query_string: %{
    #           default_operator: "AND",
    #           fields: [
    #             "names.first_name",
    #             "names.last_name",
    #             "names.full_name",
    #             "identifiers.value"
    #           ],
    #           query: q
    #         }
    #       },
    #       filter: [
    #         %{term: %{deleted: false}}
    #       ]
    #     }
    #   }
    # }

    %{
      # @query_limit,
      size: 100,
      query: %{
        bool: %{
          must: %{
            query_string: %{
              default_operator: "AND",
              fields: [
                "names.first_name",
                "names.last_name",
                "names.full_name",
                "identifiers.value"
              ],
              query: q
            }
          },
          filter: [
            %{
              bool: %{
                must_not: [
                  %{term: %{deleted: true}}
                ]
              }
            }
          ]
        }
      }
    }
  end

  def search_merged_persons(term \\ "") do
    # %{
    #   "track_total_hits" => true,
    #   "size" => 100,
    #   "query" => %{
    #     "bool" => %{
    #       "must" => get_merged_query_type(escape_characters(term)),

    #       "filter" => [
    #         %{"term" => %{"deleted" => false}},
    #         %{
    #           "script" => %{
    #             "script" => %{
    #               "source" => "doc['name_count'].size() > 0 && doc['name_count'].value > 1",
    #               "lang" => "painless"
    #             }
    #           }
    #         }
    #       ]
    #     }
    #   }
    # }
    %{
      "track_total_hits" => true,
      "size" => 100,
      "query" => %{
        "bool" => %{
          "must" => get_merged_query_type(escape_characters(term)),
          "filter" => [
            %{
              "bool" => %{
                "must_not" => [
                  %{"term" => %{"deleted" => true}}
                ]
              }
            },
            %{
              "script" => %{
                "script" => %{
                  "source" => "doc['name_count'].size() > 0 && doc['name_count'].value > 1",
                  "lang" => "painless"
                }
              }
            }
          ]
        }
      }
    }
  end

  def get_merged_query_type("") do
    [
      %{
        "match_all" => %{}
      }
    ]
  end

  def get_merged_query_type(term) do
    %{
      "query_string" => %{
        "default_operator" => "AND",
        "fields" => ["names.first_name^15", "names.last_name^15", "names.full_name^15", "identifiers.value"],
        "query" => term
      }
    }
  end
end
