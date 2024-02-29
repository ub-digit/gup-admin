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
    |> Map.put("created_at", Map.get(db_data, :created_at))
    |> Map.put("updated_at", Map.get(db_data, :updated_at))
  end

  def merge_data(existing_data, new_data) do
    existing_data
    |> List.first()
    |> Map.get("_source")
    |> merge_names(new_data)
    |> merge_departments(new_data)
    |> merge_identifiers(new_data)
    |> create_or_update_person()
    %{"message" => "Person updated"}
  end

  def update_index(%{"id" => id} = data) do
    data = Map.put(data, "id", id)
    Index.update_record(data, id, Index.get_persons_index())
  end

  def merge_names(existing_data, new_data) do
    names = Enum.uniq(existing_data["names"] ++ new_data["names"])
    Map.put(existing_data, "names", names)
  end

  def merge_departments(existing_data, new_data) do
    departments = Enum.uniq(existing_data["departments"] ++ new_data["departments"])
    Map.put(existing_data, "departments", departments)
  end

  def merge_identifiers(existing_data, new_data) do
    identifiers = Enum.uniq(existing_data["identifiers"] ++ new_data["identifiers"])
    Map.put(existing_data, "identifiers", identifiers)
  end
end
