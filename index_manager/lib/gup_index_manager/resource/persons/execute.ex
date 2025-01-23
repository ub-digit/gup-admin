defmodule GupIndexManager.Resource.Persons.Execute do

  def execute_actions({:error, error, error_log_data}) do
    GupIndexManager.Resource.Logger.log({:error, error, error_log_data})
    {:error, error, error_log_data}
  end

  def execute_actions({:ok, primary_data, :no_actions}) do
    IO.inspect("input data exist in index, no actions necessary")
    {:ok, primary_data, :no_actions}
  end

  # def execute_actions({:ok, person_input_data, [:create_or_update_person]}) do
  #   IO.inspect("input data exist in index, no actions necessary sssssssss")
  # end

  def execute_actions({:ok, primary_data, actions}) do
    # IO.inspect(actions, label: "Actions")
    result_data = Enum.reduce(actions, primary_data, fn action, primary_data ->
      execute_action(primary_data, action)
    end)
    GupIndexManager.Resource.Logger.log({:transaction, actions, result_data})
    {:ok, result_data}
  #   |> IO.inspect(label: "Primary data")

  end

  def execute_action(data, {:create_or_update_person}) do
    # Send data to create_or_update_person
    IO.puts "Create or update person"
    data = set_name_count(data)
    GupIndexManager.Resource.Persons.create_or_update_person(data)
    data
  end

  def set_name_count(data) do
    names = Map.get(data, "names", [])
    name_count = Enum.count(names)
    Map.put(data, "name_count", name_count)
  end


  def execute_action(data, {:add_name, name_data}) do
    names = Map.get(data, "names", [])
    new_names = List.insert_at(names, 0, name_data)
    Map.put(data, "names", new_names)
  end

  def execute_action(data, {:update_name, name, gup_person_id}) do
    # no gup_person_id in incoming name, but it matches the name in the data
    old_name = Enum.find(data["names"], fn name -> name["gup_person_id"] == gup_person_id end)
    names = Map.get(data, "names", [])
    |> Enum.filter(fn name -> name["gup_person_id"] != gup_person_id end)
    |> Enum.map(fn existing_name -> Map.put(existing_name, "primary", false) end)
    new_name = %{
      "first_name" => name["first_name"],
      "last_name" => name["last_name"],
      "gup_person_id" => gup_person_id,
      "primary" => true,
      "full_name" => "#{name["first_name"]} #{name["last_name"]}",
      "start_date" => name["start_date"] || old_name["start_date"] || nil,
      "end_date" => name["end_date"] || old_name["end_date"] || nil
    }

    new_names = List.insert_at(names, 0, new_name)
    |> IO.inspect(label: "New names")
    Map.put(data, "names", new_names)
  end

  def execute_action(data, {:update_name, name}) do
    IO.puts("---------- dfdd- - --------------------------------------------")
    IO.inspect(name, label: "name dsfdsdf")
    IO.inspect(data, label: "name dsfdsdf")
    # Names has the same gup_person_id, so update the name and dates
    name = Map.put(name, "full_name", "#{name["first_name"]} #{name["last_name"]}")
    |> Map.put("primary", true)
    id = name["gup_person_id"]
    |> IO.inspect(label: "ID ---<")
    names = Map.get(data, "names", [])
    |> Enum.filter(fn name -> name["gup_person_id"] != id end)
    |> Enum.map(fn existing_name -> Map.put(existing_name, "primary", false) end)
    new_names = List.insert_at(names, 0, name)
    Map.put(data, "names", new_names)
    |> IO.inspect(label: "names ---<")
    # IO.inspect(new_names, label: "new_names")
    # data
  end

  def execute_action(data, {:acquire_gup_id, name_data}) do
    name_data = Map.put(name_data, "gup_person_id", acquire_gup_person_id())
    execute_action(data, {:add_name, name_data})
  end

  def execute_action(data, {:set_primary_name, _name_data}) do
    names = Map.get(data, "names", [])
    |> set_primary_name_to_false()

    Map.put(data, "names", names)
  end

  def execute_action(data, {:add_identifier, identifier_data}) do
    identifiers = Map.get(data, "identifiers", [])
    new_identifiers = List.insert_at(identifiers, 0, identifier_data)
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
    # TODO: ask GUP for a new gup_person_id
      api_key = System.get_env("GUP_API_KEY")
      #. https://gup-server-lab.ub.gu.se/v1/people/get_next_id
      url = "#{gup_server_base_url()}/v1/poeple/get_next_id?api_key=#{api_key}"
      body = %{}
      HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
      |> case do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body |> Jason.decode!() |> Map.get("id")
        {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found"}
        {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      end

  end

  def gup_server_base_url() do
    System.get_env("GUP_SERVER_BASE_URL", "http://localhost:40191")
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

  # def log_transaction(data, {action, _data}) do
  #   IO.puts "Logging transaction for user #{action}"
  #   data
  # end

  # def log_transaction(data, {action, _data, _id}) do
  #   IO.puts "Logging transaction for user #{action}"
  #   data
  # end
end
