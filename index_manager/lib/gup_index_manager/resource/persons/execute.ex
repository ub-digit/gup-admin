defmodule GupIndexManager.Resource.Persons.Execute do

  def execute_actions({:error, error, error_log_data}) do
    IO.puts "Error: #{error}"
    IO.inspect error_log_data
  end

  def execute_actions({:ok, primary_data, actions}) do
   Enum.reduce(actions, primary_data, fn action, primary_data ->
      execute_action(primary_data, action)
      |> write_to_index(action)
      |> log_transaction(action)
    end)
    |> IO.inspect(label: "Primary data")

  end

  def execute_action(data, {:create_or_update_person} = d) do
    # GupIndexManager.Resource.Persons.create_or_update_person(data)
    # id = Map.get(data, "id", nil)
    # case id do
    #   nil -> IO.puts "Creating person"
    #   id -> IO.puts "Updating person with id #{id}"
    # end
    data
  end

  def execute_action(data, {:add_name, name_data}) do
    #IO.puts "Adding name to user"
    names = Map.get(data, "names", [])
    new_names = List.insert_at(names, 0, name_data)
    Map.put(data, "names", new_names)
    # IO.inspect(name_data, label: "Name data")
  end

  def execute_action(data, {:acquire_gup_id, name_data}) do
    #IO.puts "Adding name to user"
    name_data = Map.put(name_data, "gup_person_id", acquire_gup_person_id())
    execute_action(data, {:add_name, name_data})
    # IO.inspect(name_data, label: "Name data")
  end

  def execute_action(data, {:add_identifier, identifier_data}) do
    identifiers = Map.get(data, "identifiers", [])
    new_identifiers = List.insert_at(identifiers, 0, identifier_data)
    Map.put(data, "identifiers", new_identifiers)
  end

  def execute_action(data, {:delete_person, id}) do
    IO.puts "Deleting person #{id}"
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

  def log_transaction(data, {action}) do
    IO.puts "Logging transaction for user #{action}"
    data
  end

  def log_transaction(data, {action, _data}) do
    IO.puts "Logging transaction for user #{action}"
    data
  end
end
