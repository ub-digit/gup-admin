defmodule GupIndexManager.Resource.Persons.Execute do

  require Logger

  def execute_actions({:error, error, error_log_data}) do
    GupIndexManager.Resource.Logger.log({:error, error, error_log_data})
    {:error, error, error_log_data}
  end

  def execute_actions({:ok, primary_data, :no_actions}) do
    # IO.inspect("input data exist in index, no actions necessary")
    {:ok, primary_data, :no_actions}
  end

  # def execute_actions({:ok, person_input_data, [:create_or_update_person]}) do
  #   IO.inspect("input data exist in index, no actions necessary sssssssss")
  # end

  def execute_actions({:ok, primary_data, actions}) do
    Logger.debug("IM:R.execute_actions: ACTIONS: #{inspect(actions)}")
    result_data = Enum.reduce(actions, primary_data, fn action, primary_data ->
      execute_action(primary_data, action)
    end)

    Logger.debug("IM:R.execute_actions: result_data: #{inspect(result_data)}")
    {:ok, result_data, actions}

  end

  def execute_action(data, {:update_departments, department_data}) do
    # remove all departments that has the same name as department_data
      departments = Map.get(data, "departments", [])
      |> Enum.filter(fn department -> department["name"] != department_data["name"] end)
      |> List.insert_at(0, department_data)
    Map.put(data, "departments", department_data)
  end

  def execute_action(data, {:add_department, department_data}) do
    departments = Map.get(data, "departments", [])
    new_departments = List.insert_at(departments, 0, department_data)
    Map.put(data, "departments", new_departments)
  end

  def execute_action(data, {:create_or_update_person}) do
    # Send data to create_or_update_person
    # IO.puts "Create or update person"
    # check if data needs to be sent to gup
    data = set_name_count(data)
    GupIndexManager.Resource.Persons.create_or_update_person(data)
    data
  end


  def execute_action(data, {:add_name, name_data}) do
    names = Map.get(data, "names", [])
    |> delete_unwanted_names(name_data)
    new_names = List.insert_at(names, 0, name_data)
    Map.put(data, "names", new_names)
  end

  def execute_action(data, {:update_name, name}) do
    name_to_update = Enum.find(data["names"], fn n -> n["gup_person_id"] == name["gup_person_id"] end)
    start_date = name["start_date"] || name_to_update["start_date"] || nil
    end_date = name["end_date"] || name_to_update["end_date"] || nil
    updated_name =
    Map.put(name_to_update, "start_date", start_date)
    |> Map.put("end_date", end_date)
    |> Map.put("first_name", name["first_name"])
    |> Map.put("last_name", name["last_name"])
    |> Map.put("full_name", "#{name["first_name"]} #{name["last_name"]}")

    names = Map.get(data, "names", [])
    |> Enum.filter(fn n -> n["gup_person_id"] != name["gup_person_id"] end)
    |> Kernel.++([updated_name])
    |> List.flatten()

    data |> Map.put("names", names)

  end

  def execute_action(data, {:acquire_gup_person_id, name_data}) do
    name_data = Map.put(name_data, "gup_person_id", GupIndexManager.Resource.Gup.get_next_gup_id(GupIndexManager.Resource.Gup.people()))
    Logger.debug("IM:R.execute_action: acquire_gup_id: #{inspect(name_data)}")
    execute_action(data, {:add_name, name_data})
  end

  def execute_action(data, {:set_primary_name, name_data}) do
    names = Map.get(data, "names", [])
    |> Enum.map(fn name ->
      Map.put(name, "primary", false)
    end)
    |> Enum.map(fn name ->
      if name["first_name"] == name_data["first_name"] && name["last_name"] == name_data["last_name"] do
        # check if name and name_data both have a non-nil value for gup_person_id.
        if name["gup_person_id"] && name_data["gup_person_id"] && name["gup_person_id"] != name_data["gup_person_id"] do
          Map.put(name, "primary", false)
        else
          Map.put(name, "primary", true)
        end
      else
        name
      end
    end)
    Map.put(data, "names", names)
  end

  def execute_action(data, {:add_identifier, identifier_data}) do
    identifiers = Map.get(data, "identifiers", [])
    new_identifiers = List.insert_at(identifiers, 0, identifier_data)
    Map.put(data, "identifiers", new_identifiers)
  end

  def execute_action(data, {:delete_identifier, identifier_data}) do
    identifiers = Map.get(data, "identifiers", [])
    new_identifiers = Enum.filter(identifiers, fn identifier -> identifier["value"] != identifier_data["value"] end)
    Map.put(data, "identifiers", new_identifiers)
  end

  def execute_action(data, {:delete_person, id}) do
    IO.puts "Deleting person #{id}"
    GupIndexManager.Resource.Persons.delete_person(id)
    data
  end

  def execute_action(data, {:update_year_of_birth, year_of_birth_data}) do
    Map.put(data, "year_of_birth", year_of_birth_data)
  end

  def acquire_gup_person_id() do
    Logger.debug("IM:R.acquire_gup_person_id")
      api_key = System.fetch_env!("GUP_API_KEY")
      url = "#{gup_server_base_url()}/v1/people/get_next_id?api_key=#{api_key}"
      Logger.debug("IM:R.acquire_gup_person_id: url: #{url}")
      HTTPoison.get(url, [{"Content-Type", "application/json"}])
      |> case do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body |> Jason.decode!() |> Map.get("id")
        {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found"}
        {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      end
  end

  def gup_server_base_url() do
    System.fetch_env!("GUP_SERVER_BASE_URL")
  end

  def write_to_index(data, {:acquire_gup_person_id, _data}), do: data # no index update needed as data is passed to :add_name action
  def write_to_index(data, action) do
    IO.puts "Writing to index: #{ action |> elem(0) }"
    data
  end

  def set_primary_name_to_false(names) do
    Enum.map(names, fn name ->
      if name["primary"] do
        Map.put(name, "primary", false)
      else
        name
      end
    end)
  end

  def log_transaction(data, action) do
    IO.puts "Logging transaction for user #{action |> elem(0)}"
    data
  end

  def set_name_count(data) do
    names = Map.get(data, "names", [])
    name_count = Enum.count(names)
    Map.put(data, "name_count", name_count)
  end

  defp delete_unwanted_names(names, name_data) do
    Enum.filter(names, fn name ->
      !(name["first_name"] == name_data["first_name"] && name["last_name"] == name_data["last_name"] && name["gup_person_id"] == name_data["gup_person_id"])
    end)
  end
end
