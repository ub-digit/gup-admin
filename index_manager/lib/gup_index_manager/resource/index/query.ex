defmodule GupIndexManager.Resource.Index.Query do
  def find_person_by_identifiers([]), do: nil
  def find_person_by_identifiers(identifiers) do
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
                "term" => %{
                  "deleted" => false
                }

              },
              %{
                "query_string" => %{
                  "fields" => ["identifiers.value.keyword"],
                  "query" => "\"" <> identifier["value"] <> "\"" #escape_characters(identifier["identifier_value"]),
                }
              },
              %{
                "query_string" => %{
                  "fields" => ["identifiers.code"],
                  "query" => identifier["code"]
                }
              }
            ]
          }
        }
      ]
    end)
  end

  def find_person_by_gup_id(gup_id) do
    %{
      "query" => %{
        "bool" => %{
          "must" => [
            %{
              "term" => %{
                "names.gup_person_id" => gup_id
              }
            }
          ],
          "must_not" => [
            %{
              "term" => %{
                "deleted" => true
              }
            }
          ]
        }
      }
    }

  end

  def find_person_by_gup_admin_id(id) do
    %{
      "query" => %{
      "bool" => %{
        "must" => [
        %{
          "term" => %{
          "id" => id
          }
        }
        ],
        "must_not" => [
          %{
            "term" => %{
              "deleted" => true
            }
          }
        ]
      }
      }
    }
  end

  def get_all_persons do
    %{

    }
  end
end
