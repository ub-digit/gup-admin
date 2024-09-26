defmodule MergeTestHelpers do
  alias GupIndexManager.Resource.Index


  ################################################################################################
  # This module contains helper functions for the tests in the CreateOrUpdatePersonTest module
  ################################################################################################

  # Index functions
  def clear_index() do
    IO.puts "clearing and creating index for testing"
    # get the index name from the config
    index_name = get_person_index_name()

    # get the elastic url
    elastic_url = Index.elastic_url()

    # delete the index
    Elastix.Index.delete(elastic_url, index_name)

    # create the index
    Index.create_index(index_name)

  end

  def get_person_index_name() do
    # Name for test index is stored in the config
    Application.get_env(:gup_index_manager, :person_index_name)
  end


  def index_data(data) do
    index = Index.get_persons_index()
    url = Index.elastic_url()
    for person <- data do
      IO.inspect(person["id"], label: "indexing person id")
      Elastix.Document.index(url, index, "_doc", person["id"], person, [])

    end
    Elastix.Index.refresh(url, index)
  end


  # data generation functions
  def generate_person_data(gup_admin_person_id \\ nil) do
    %{
      "id" => gup_admin_person_id,
      "updated_at" => "2019-01-01T00:00:00+01:00",
      "created_at" => "2019-01-01T00:00:00+01:00",
      "names" => [],
      "year_of_birth" => 1977,
      "identifiers" => [],
      "departments" => []
    }
  end

  def add_name_forms(data, name_forms) do
    old_names = Map.get(data, "names", [])
    names = Enum.map(name_forms, fn {first_name, last_name, id} ->
      %{
        "start_date" => "2019-01-01T00:00:00+01:00",
        "end_date" => "2019-12-31T00:00:00+01:00",
        "first_name" => first_name,
        "last_name" => last_name,
      } |> set_gup_person_id(id)
    end)
    Map.put(data, "names", names ++ old_names)
  end

  defp set_gup_person_id(data, id) do
    if id do
      Map.put(data, "gup_person_id", id)
    else
      data
    end
  end

  def set_gup_admin_id(data, id) do
    Map.put(data, "id", id)
  end

  def clear_gup_admin_id(data) do
    Map.delete(data, "id")
  end

  def clear_name_forms(data) do
    Map.put(data, "names", [])
  end

  def add_identifiers(data, identifiers) do
    old_identifiers = Map.get(data, "identifiers", [])
    identifiers = Enum.map(identifiers, fn {code, value} ->
      %{
        "code" => code,
        "value" => value,
      }
    end)
    Map.put(data, "identifiers", identifiers ++ old_identifiers)
  end

  def clear_identifiers(data) do
    Map.put(data, "identifiers", [])
  end
end
