defmodule GupIndexManager.Resource.Persons do
  alias GupIndexManager.Resource.Index.Search
  alias GupIndexManager.Resource.Index
  alias GupIndexManager.Model.Person

  def create_or_update(data) do
    case Search.find_person_by_identifiers(data["identifiers"]) do
      {false, _} -> create_person(data)
      {true, hits} -> update_person(hits, data)
    end
  end

  def create_person(data) do
    attrs = %{
      "json" => data |> Jason.encode!()
    }
    %GupIndexManager.Model.Person{}
    |> Person.changeset(attrs)
    |> GupIndexManager.Repo.insert_or_update()
    |> elem(1)
    |> Map.get(:id)
    |> add_to_index(data)
  end

  def add_to_index(id, data) do
    Map.put(data, "id", id)
    |> Index.update_record(id, Index.get_persons_index())
  end

  def update_person(hits, data) do
    IO.inspect("THIS PERSON EXISTS -------------------------------------------------------------------------------- ")
    # attrs = %{
    #   "json" => data |> Jason.encode!()
    # }
    # person
    # |> Person.changeset(attrs)
    # |> GupIndexManager.Repo.insert_or_update()
    # |> elem(1)
    # |> Map.get(:id)
    # |> add_to_index(data)
  end



end
