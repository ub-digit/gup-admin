defmodule GupAdmin.Resource.Search.Query do
  @query_limit 1000

  def base(term) do
    %{
      "size" => @query_limit,
      "query" => %{
        "bool" => %{
          "must" => get_query_type(term)
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
        "fields" => ["title^15", "id"],
        "query" => term
        # "analyzer" => "edge_ngram_analyzer"
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
              "id.keyword" => id
            }
          }
        }
      }
    }
  end
end
