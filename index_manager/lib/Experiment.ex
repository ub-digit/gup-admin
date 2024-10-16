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

  end

  @hello "Hello"

  def testar(@hello) do
    IO.inspect("Yes it works")
  end

  def testar(_) do
    IO.inspect("All others")
  end

  def add_data do
    #  MergeTestHelpers.generate_person_data()
    # |> MergeTestHelpers.add_name_forms([{"Anna", "Wåhlin", "101010101"}, {"Alberto C.", "Naveira Garabato", "202020202"}, {"Ulla", "Skoog", nil}])
    # |> MergeTestHelpers.add_identifiers([{"X_ACCOUNT", "xb1111"}])
    # |> GupIndexManager.Resource.Persons.Merger.merge()
    # |> IO.inspect(label: "Merged data")
    # |> GupIndexManager.Resource.Persons.Execute.execute_actions()

    # MergeTestHelpers.generate_person_data()
    # |> MergeTestHelpers.add_name_forms([{"Anna", "Wåhlin", "fffff101010101"}])
    # |> MergeTestHelpers.add_identifiers([{"X_ACCOUNT", "xb111wwwwww1"}])
    # |> GupIndexManager.Resource.Persons.sanitize_data()
    # |> GupIndexManager.Resource.Persons.Merger.merge()
    # |> IO.inspect(label: "Merged data")
    # |> GupIndexManager.Resource.Persons.Execute.execute_actions()

    MergeTestHelpers.generate_person_data()
    |> MergeTestHelpers.set_gup_admin_id("101")
    |> MergeTestHelpers.add_name_forms([{"George", "Cloney", "222222"}])
    |> MergeTestHelpers.add_identifiers([{"ORCID", "orcid1111"}, {"yada", "yada"}])
    |> GupIndexManager.Resource.Persons.sanitize_data()
    |> GupIndexManager.Resource.Persons.Merger.merge()
    |> IO.inspect(label: "Merged data")
    |> GupIndexManager.Resource.Persons.Execute.execute_actions()

  end

end
