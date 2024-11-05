defmodule GupIndexManager.Resource.Persons.Execute do

  def execute_actions({:error, error, error_log_data}) do
    IO.puts "Error: #{error}"
    IO.inspect error_log_data
  end

  def execute_actions({:ok, _primary_data, :no_actions}) do
    IO.inspect("input data exist in index, no actions necessary")
  end

  # def execute_actions({:ok, person_input_data, [:create_or_update_person]}) do
  #   IO.inspect("input data exist in index, no actions necessary sssssssss")
  # end

  def execute_actions({:ok, primary_data, actions}) do
    IO.inspect("asdasdasdasdasdasd")
    %{"passed" => "to execute_actions"}
   Enum.reduce(actions, primary_data, fn action, primary_data ->
      execute_action(primary_data, action)
      |> write_to_index(action)
      |> log_transaction(action)
    end)
  #   |> IO.inspect(label: "Primary data")

  end

  def execute_action(data, {:create_or_update_person}) do
    # Send data to create_or_update_person
    IO.puts "Create or update person"
    GupIndexManager.Resource.Persons.create_or_update_person(data)
    data
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
    Map.put(data, "names", new_names)
  end

  def execute_action(data, {:update_name, name}) do
    # Names has the same gup_person_id, so update the name and dates
    IO.puts "Update name"
    data
  end

  def execute_action(data, {:acquire_gup_id, name_data}) do
    name_data = Map.put(name_data, "gup_person_id", acquire_gup_person_id())
    execute_action(data, {:add_name, name_data})
  end

  def execute_action(data, {:add_identifier, identifier_data}) do
    identifiers = Map.get(data, "identifiers", [])
    new_identifiers = List.insert_at(identifiers, 0, identifier_data)
    Map.put(data, "identifiers", new_identifiers)
  end

  def execute_action(data, {:delete_person, id}) do
    IO.puts "Deleting person #{id}"
    GupIndexManager.Resource.Persons.delete_person(id)
    # get user from index with id
    # mark user as deleted "deleted" => true
    # update index
    # update db
    data
  end

  def acquire_gup_person_id() do
    :rand.uniform(1000000)
    |> to_string()
    |> Kernel.<>(" holy smoke!")
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
