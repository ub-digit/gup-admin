defmodule Experiment do
  def check_env(var_name) do
    System.get_env(var_name)
    |> IO.inspect(label: "#{var_name} value")
  end

  def convert_author_data do
    %{
      "authors" => [
        %{
          "affiliations" => [
            %{
              "department" => "Institutionen för marina vetenskaper"
            }
          ],
          "person" => [
            %{
              "first_name" => "Anna",
              "id" => 104485,
              "identifiers" => [
                %{
                  "type" => "xkonto",
                  "value" => "xwahla"
                }
              ],
              "last_name" => "Wåhlin",
              "year_of_birth" => 1970
            }
          ]
        },
        %{
          "affiliations" => [
            %{
              "department" => "Extern"
            }
          ],
          "person" => [
            %{
              "first_name" => "Alberto C.",
              "id" => 935155,
              "identifiers" => [],
              "last_name" => "Naveira Garabato",
              "year_of_birth" => nil
            }
          ]
        }
      ]
    }
    |> Map.get("authors")
    |> Enum.map(fn author ->
      %{
        "departments" => %{
           "name" => Map.get(author, "affiliations") |> List.first() |> Map.get("department")
        },
        "id" => Map.get(author, "person") |> List.first() |> Map.get("id"),
        "name" => (Map.get(author, "person") |> List.first() |> Map.get("first_name")) <> " " <> (Map.get(author, "person") |> List.first() |> Map.get("last_name"))
      }
    end)
  end

  def tt(%{"a" => [%{"af" => _}]} = m) do
    IO.inspect(m)
  end

  def tt(d) do
    IO.inspect("NO AFFILIATIONS")
    d
  end

  @hello "Hello"

  def testar(@hello) do
    IO.inspect("Yes it works")
  end

  def testar(_) do
    IO.inspect("All others")
  end


  def has_any() do
    [%{"id" => 1, "name" => "Anna"}, %{"id" => 2, "name" => "Bertil"}]
    |> Enum.any?(fn x -> x["id"] == 1 end)
  end

end
