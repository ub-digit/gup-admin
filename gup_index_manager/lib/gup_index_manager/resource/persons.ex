defmodule GupIndexManager.Resource.Persons do
  alias GupIndexManager.Resource.Index.Search
  alias GupIndexManager.Resource.Index
  alias GupIndexManager.Model.Person

  def create_or_update(data) do
    case Search.find_person_by_identifiers(data["identifiers"]) do
      {false, _} -> create_or_update_person(data)
      {true, hits} -> merge_data(hits, data)
    end
  end

  def create_or_update_person(data) do
    id = Map.get(data, "id", nil)
    attrs = %{
      "json" => data |> Jason.encode!()
    }
    Person.find_by_id(id)
    |> Person.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)
    |> set_meta(data)
    |> update_index()
  end

  def set_meta(db_data, data) do
    data
    |> Map.put("id", Map.get(db_data, :id))
    |> Map.put("created_at", Map.get(db_data, :inserted_at))
    |> Map.put("updated_at", Map.get(db_data, :updated_at))
  end

  def merge_data(existing_data, new_data) do
    existing_data
    |> List.first()
    |> Map.get("_source")
    |> merge_lists(new_data, "names")
    |> merge_lists(new_data, "departments")
    |> merge_lists(new_data, "identifiers")
    |> create_or_update_person()
    %{"message" => "Person updated"}
  end

  def update_index(%{"id" => id} = data) do
    IO.inspect(data, label: "data")
    data = Map.put(data, "id", id)
    Index.update_record(data, id, Index.get_persons_index())
  end

  def merge_lists(existing_data, new_data, list_name) do
    res = Enum.uniq(Map.get(existing_data, list_name, []) ++ Map.get(new_data, list_name, []))
    Map.put(existing_data, list_name, res)
  end

  def get_all do
    Search.get_all_persons()
  end
end
