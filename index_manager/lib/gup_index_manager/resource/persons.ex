defmodule GupIndexManager.Resource.Persons do
  alias GupIndexManager.Resource.Index.Search
  alias GupIndexManager.Resource.Index
  alias GupIndexManager.Model.Person

  require Logger

  ################################
  # Vocabulary
  # IM/im = index manager

  def create(person_data_as_map) do
    Logger.debug("IM:R.create: person_data_as_map: #{inspect(person_data_as_map)}")
    create_or_update_person(person_data_as_map)
  end

  def update(id, %{"id" => id} = person_data_as_map) do
    Logger.debug("IM:R.update: id: #{id}, person_data_as_map: #{inspect(person_data_as_map)}")
    create_or_update_person(person_data_as_map)
  end
  def update(url_id, %{"id" => data_id}) do
    Logger.debug("IM:R.update: ID_MISMATCH_BETWEEN_URL_AND_DATA url_id: #{url_id}, data_id: #{data_id}")
    {:error, %{errors: %{im_message: "ID_MISMATCH_BETWEEN_URL_AND_DATA"}}}
  end

  def delete(doc_id) do
    Logger.debug("IM:R.delete: doc_id: #{doc_id}")
    delete_person(doc_id)
  end

  # -----------------------------------------------------------------------------------------------

  def create_or_update(data) do
    data = data
    # |> sanitize_data()
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
    |> IO.inspect(label: "Person updated")
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
    |> clear_primary_name()
    |> merge_lists(new_data, "names")
    |> merge_lists(new_data, "departments")
    |> merge_lists(new_data, "identifiers")
    |> set_merge_count()
    |> create_or_update_person()
    %{"message" => "Person updated"}
  end

  def set_merge_count(data) do
    merge_count = Map.get(data, "merge_count", 0) + 1
    Map.put(data, "merge_count", merge_count)
  end

  def update_index(%{"id" => id} = data) do
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

  # def sanitize_data(data) do
  #   %{
  #     "id" => Map.get(data, "id", nil),
  #     "names" => sanitize_names(Map.get(data, "names", [])),
  #     "departments" => Map.get(data, "departments", []),
  #     "identifiers" => Map.get(data, "identifiers", []),
  #     "year_of_birth" => Map.get(data, "year_of_birth", nil),
  #     "email" => Map.get(data, "email", nil),
  #   }
  # end

  # def sanitize_names(names) do
  #   names
  #   |> Enum.map(fn name ->
  #     %{
  #       "first_name" => Map.get(name, "first_name", ""),
  #       "last_name" => Map.get(name, "last_name", ""),
  #       "full_name" => "#{Map.get(name, "first_name", "")} #{Map.get(name, "last_name", "")}",
  #       "start_date" => Map.get(name, "start_date", nil),
  #       "end_date" => Map.get(name, "end_date", nil),
  #       "gup_person_id" => Map.get(name, "gup_person_id", nil),
  #       "primary" => true

  #     }
  #   end)
  # end

  def clear_primary_name(data) do
    data
    |> Map.put("names", Enum.map(Map.get(data, "names", []), fn name ->
      Map.put(name, "primary", false)
    end))
  end

  def delete_person(id) do
    time_deleted = DateTime.utc_now()
   # Fetch the person fron the index
    data = GupIndexManager.Resource.Index.Search.find_person_by_gup_admin_id(id) # Index object
    |> elem(1)
    |> List.first()
    |> Map.get("_source")
    |> Map.put("deleted", true)
    |> Map.put("deleted_at", time_deleted)

    Index.update_record(data, id, Index.get_persons_index())

    # set db_person as deleted
    db_person = Person.find_by_id(id)
    attrs = %{
      "json" => data |> Jason.encode!(),
      "deleted" => true,
      "deleted_at" => time_deleted
    }
    db_person
    |> Person.changeset(attrs)
    |> GupIndexManager.Repo.update()
  end
end
