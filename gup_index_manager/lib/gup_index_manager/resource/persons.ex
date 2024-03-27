defmodule GupIndexManager.Resource.Persons do
  alias GupIndexManager.Resource.Index.Search
  alias GupIndexManager.Resource.Index
  alias GupIndexManager.Model.Person

  def create_or_update(input_data) do
    input_data
    |> sanitize_data()
    |> has_x_account()
    |> get_existing_person_data()
    # |> get_existing_person_data_by_identifiers()
    |> merge_data()
    # |> remove_old_record_from_index()
    |> create_or_update_person()
    |> case do
      {:error, message} -> %{"message" => message}
      _ -> %{"message" => "Person created or updated"}

    end
  end

  def get_existing_person_data({_existing_xaccount = false, input_data}) do
  # No x account in incoming data, check if gup_person_id exists in index
  # If gup_person_id exists in index, return {data, existing_data} else return "data"
    IO.inspect("NO X ACCOUNT IN DATA or NOT Found by xaccount, trying to find by gup_person_id")
    gup_person_id = get_gup_person_id(input_data)
    Search.find_person_by_gup_person_id(gup_person_id)
    |> case do
      {true, existing_data} -> {existing_data, input_data}
      {false, nil} -> input_data
    end
    input_data
  end

  def get_existing_person_data({_existing_xaccount = true, input_data, x_account}) do
  # X account exists in incoming data
  # Check if x account exists in index
  # If x account exists in index, merge
  # Also check for gup_person_id in index and merge and delete old record
    IO.inspect("X ACCOUNT EXISTS IN DATA")
    Search.find_person_by_x_account(x_account)
    |> case do
      {true, existing_data} -> {existing_data, input_data}
      {false, nil} -> get_existing_person_data({false, input_data})
    end
  end

  def get_existing_person_data_by_identifiers({existing_data, data}) do
    IO.inspect("Existing data already found, returning data")
    {existing_data, data}
  end

  def get_existing_person_data_by_identifiers(data) do
    IO.inspect("No existing data, trying by identifiers")
    identifiers = Map.get(data, "identifiers", [])
    Search.find_person_by_identifiers(identifiers)
    |> case do
      {true, existing_data} -> {existing_data, data}
      {false, nil} -> data
    end
  end

  # def remove_old_record_from_index(data), do: data
  # def remove_old_record_from_index({data, _d}) do
  #   Index.delete_record(data, Index.get_persons_index())
  # end

  def get_gup_person_id(data) do
    Map.get(data, "names", nil)
    |> List.first()
    |> Map.get("gup_person_id", nil)
  end

  def has_x_account(input_data) do
    input_data["identifiers"]
    |> Enum.filter(fn id -> id["code"] == "X_ACCOUNT" end)
    |> case do
      [] -> {false, input_data}
      [account_data] -> {true, input_data, Map.get(account_data, "value")}
    end
  end

  def create_or_update_person({:error, _message} = error), do: error
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


  def merge_data({existing_data, new_data}) do
    IO.inspect("MERGING DATA")
    existing_data
    |> clear_primary_name()
    |> merge_names(new_data)
    |> merge_lists(new_data, "identifiers")
    |> merge_lists(new_data, "departments")
    |> set_merge_count()
  end

  def merge_data(data) do
    IO.inspect("NO EXISTING DATA, RETURNING NEW DATA")
    data
  end

  def merge_names(existing_data, data) do
    IO.inspect("MERGING NAMES")
    # Check for the gup_person_id in the new data
    existing_names = Map.get(existing_data, "names", [])
    new_name = Map.get(data, "names", []) |> List.first()

    # Check if the new names gup_person_id already exists in the existing names
    names = existing_names
    |> Enum.any?(fn n -> Map.get(n, "gup_person_id") == Map.get(new_name, "gup_person_id") end)
    |> case do
      true -> update_name(existing_names, new_name)
      false -> add_name(existing_names, new_name)
    end

    Map.put(existing_data, "names", names)
  end

  def update_name(existing_names, new_name) do
    new_name = Map.put(new_name, "primary", true)
    Enum.reject(existing_names, fn name -> Map.get(name, "gup_person_id") == Map.get(new_name, "gup_person_id") end)
    |> List.insert_at(0, new_name)
  end

  def add_name(existing_names, new_name) do
    new_name = Map.put(new_name, "primary", true)
    List.insert_at(existing_names, 0, new_name)
  end

  def set_merge_count({:error, _error} = error), do: error

  def set_merge_count(data) do
    merge_count = Map.get(data, "merge_count", 0) + 1
    Map.put(data, "merge_count", merge_count)
  end

  def update_index(%{"id" => id} = data) do
    data = Map.put(data, "id", id)
    Index.update_record(data, id, Index.get_persons_index())
  end

  def merge_lists({:error, _error} = error, _, _list), do: error

  def merge_lists(existing_data, new_data, list_name) do
    IO.inspect("MERGING LISTS")
    existing_data_list = Map.get(existing_data, list_name, [])
    new_data_list = Map.get(new_data, list_name, [])
    lists_are_mergeable(existing_data_list, new_data_list)
    |> case do
      {:error, message} -> {:error, message}
      {:ok, _message} -> Map.put(existing_data, list_name, merge_lists(existing_data_list, new_data_list))
    end
  end


  def merge_lists(existing_data_list, new_data_list) do
    Enum.uniq(existing_data_list ++ new_data_list)
  end

  def lists_are_mergeable(existing_data_list, new_data_list) do
    Enum.map(existing_data_list, fn existing_item ->
      Enum.any?(new_data_list, fn new_item ->  new_item["code"] == existing_item["code"] && new_item["value"] != existing_item["value"] end)
      # TODO: Log conflicting data?
    end)
    |> Enum.member?(true)
    |> case  do
      true -> {:error, "Cannot merge persons, conflicting data found in lists"}
      false -> {:ok, "Lists are mergeable"}
    end
  end


  def get_all do
    Search.get_all_persons()
  end

  def sanitize_data(input_data) do
    %{
      "id" => Map.get(input_data, "id", nil),
      "names" => sanitize_names(Map.get(input_data, "names", [])),
      "departments" => Map.get(input_data, "departments", []),
      "identifiers" => Map.get(input_data, "identifiers", []),
      "year_of_birth" => Map.get(input_data, "year_of_birth", nil),
      "email" => Map.get(input_data, "email", nil),
    }
  end

  def sanitize_names(names) do
    names
    |> Enum.map(fn name ->
      %{
        "first_name" => Map.get(name, "first_name", ""),
        "last_name" => Map.get(name, "last_name", ""),
        "full_name" => "#{Map.get(name, "first_name", "")} #{Map.get(name, "last_name", "")}",
        "start_date" => Map.get(name, "start_date", nil),
        "end_date" => Map.get(name, "end_date", nil),
        "gup_person_id" => Map.get(name, "gup_person_id", nil),
        "primary" => true

      }
    end)
  end

  def clear_primary_name(data) do
    data
    |> Map.put("names", Enum.map(Map.get(data, "names", []), fn name ->
      Map.put(name, "primary", false)
    end))
  end
end
