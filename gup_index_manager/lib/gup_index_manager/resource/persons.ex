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
    |> create_or_update_person()
    |> remove_old_record_from_index(input_data)
    |> case do
      {:error, message} -> %{"message" => message}
      _ -> %{"message" => "Person created or updated"}

    end
  end

  def get_existing_person_data({_existing_xaccount = false, input_data}) do
  # No x account in incoming data, check if gup_person_id exists in index
  # If gup_person_id exists in index, return {data, existing_data} else return "data"
  # IO.inspect("NO X ACCOUNT IN DATA or NOT Found by xaccount, trying to find by gup_person_id")
    gup_person_id = get_gup_person_id(input_data)
    Search.find_person_by_gup_person_id(gup_person_id)
    |> case do
      {true, existing_data} -> {existing_data, input_data, :no_gup_person_deletion}
      {false, nil} -> {nil, input_data, :no_gup_person_deletion}
    end
  end

  def get_existing_person_data({_existing_xaccount = true, input_data, x_account}) do
  # X account exists in incoming data
  # Check if x account exists in index
  # If x account exists in index, merge
  # Also check for gup_person_id in index and merge and delete old record
  # IO.inspect("X ACCOUNT EXISTS IN DATA")
    possible_x_account = Search.find_person_by_x_account(x_account)
    possible_x_account_id = possible_x_account
    |> case do
      {true, existing_data} -> existing_data["id"]
      {false, nil} -> nil
    end
    gup_person_id = get_gup_person_id(input_data)
    possible_gup_person = Search.find_person_by_gup_person_id(gup_person_id)
    possible_gup_person_id = possible_gup_person
    |> case do
      {true, existing_data} -> existing_data["id"]
      {false, nil} -> nil
    end

    case {possible_x_account, possible_x_account_id, possible_gup_person_id} do
      {{true, existing_data}, _existing_id, nil} -> {existing_data, input_data, :no_gup_person_deletion}
      {{true, existing_data}, existing_id, gup_person_id} when existing_id != gup_person_id -> {existing_data, input_data, gup_person_id}
      {{true, existing_data}, _existing_id, _gup_person_id} -> {existing_data, input_data, :no_gup_person_deletion}
      _ -> possible_gup_person
      |> case do
        {true, existing_data} -> {existing_data, input_data, :no_gup_person_deletion}
        {false, nil} -> {nil, input_data, :no_gup_person_deletion}
      end

    end
  end

  def get_existing_person_data_by_identifiers({existing_data, data}) do
  # IO.inspect("Existing data already found, returning data")
    {existing_data, data}
  end

  def get_existing_person_data_by_identifiers(data) do
   # IO.inspect("No existing data, trying by identifiers")
    identifiers = Map.get(data, "identifiers", [])
    Search.find_person_by_identifiers(identifiers)
    |> case do
      {true, existing_data} -> {existing_data, data}
      {false, nil} -> data
    end
  end


  def remove_old_record_from_index({{:error, _msg}, _} = error), do: error
  def remove_old_record_from_index({existing_data, :no_gup_person_deletion}, _input_data), do: existing_data
  def remove_old_record_from_index({existing_data, gup_admin_id}, _input_data) when not is_atom(gup_admin_id) do
    Index.delete_record(gup_admin_id, Index.get_persons_index())
    # Delete record from database
    GupIndexManager.Model.Person.find_by_id(gup_admin_id)
    |> GupIndexManager.Repo.delete()
    existing_data
  end


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

  def create_or_update_person({{:error, _message}, _state} = error), do: error
  def create_or_update_person({data, deletion_state}) do
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
    |> then(fn data -> {data, deletion_state} end)
  end

  def set_meta(db_data, data) do
    data
    |> Map.put("id", Map.get(db_data, :id))
    |> Map.put("created_at", Map.get(db_data, :inserted_at))
    |> Map.put("updated_at", Map.get(db_data, :updated_at))
  end


  def merge_data({existing_data, new_data, deletion_state}) when is_map(existing_data) do
    #IO.inspect("MERGING DATA")
    existing_data
    |> clear_primary_name()
    |> merge_names(new_data)
    |> merge_lists(new_data, "identifiers")
    |> merge_lists(new_data, "departments")
    |> set_merge_count()
    |> then(fn data -> {data, deletion_state} end)
  end

  def merge_data({nil, data, deletion_state}) do
    #IO.inspect("NO EXISTING DATA, RETURNING NEW DATA")
    {data, deletion_state}
  end

  def merge_names(existing_data, data) do
    #IO.inspect("MERGING NAMES")
    # Check for the gup_person_id in the new data
    existing_names = Map.get(existing_data, "names", [])
    new_name = Map.get(data, "names", []) |> List.first()

    # Check if the new names gup_person_id already exists in the existing namesid
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

    lists_are_mergeable(existing_data, new_data, list_name)
    |> case do
      {:error, message} -> {:error, message}
      {:ok, existing_data_list, new_data_list} -> Map.put(existing_data, list_name, merge_lists(existing_data_list, new_data_list))
    end
  end


  def merge_lists(existing_data_list, new_data_list) do
    Enum.uniq(existing_data_list ++ new_data_list)
  end

  def lists_are_mergeable(existing_data, new_data, list_name) do
    existing_data_list = Map.get(existing_data, list_name, [])
    new_data_list = Map.get(new_data, list_name, [])
    Enum.map(existing_data_list, fn existing_item ->
      Enum.any?(new_data_list, fn new_item ->  new_item["code"] == existing_item["code"] && new_item["value"] != existing_item["value"] end)
      # TODO: Log conflicting data?

    end)
    |> Enum.member?(true)
    |> case  do
      true -> log_conflicting_data(existing_data, new_data)
      false -> {:ok, existing_data_list, new_data_list}
    end
  end

  def log_conflicting_data(existing_data, new_data) do
    # append the conflicting data to the file
    # return an error
    merg_conflict_log_path = get_conflict_log_path()
    File.mkdir_p!(Path.dirname(merg_conflict_log_path))
    {:ok, file} = File.open merg_conflict_log_path, [:append]

    msg = "--------------------------------- Merge Conflict start -------------------------------------------\n"
    |> Kernel.<>(("Existing data: \n"))
    |> Kernel.<>(Jason.encode!(existing_data, pretty: true))
    |> Kernel.<>(("\nNew data: \n"))
    |> Kernel.<>(Jason.encode!(new_data, pretty: true))
    |> Kernel.<>(("\n--------------------------------- Merge Conflict end ---------------------------------------------\n\n"))

    IO.write(file, msg)
    File.close(file)
    {:error, "Cannot merge persons, conflicting data found in lists"}
  end

  def get_all do
    Search.get_all_persons()
  end

  def get_conflict_log_path do
    System.get_env("INDEX_MANAGER_MERGE_PERSON_CONFLICTS_LOG_PATH", "merge_conflicts.log")
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
