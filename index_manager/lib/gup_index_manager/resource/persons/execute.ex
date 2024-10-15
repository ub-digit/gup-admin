defmodule GupIndexManager.Resource.Persons.Execute do




  def execute_actions({:error, error, error_log_data}) do
    IO.puts "Error: #{error}"
    IO.inspect error_log_data
  end

  def execute_actions({:ok, primary_data, actions}) do
   Enum.reduce(actions, primary_data, fn action, primary_data ->
      execute_action(primary_data, action)
      # |> log_transaction()
    end)
  end

  def execute_action(data, {:create_or_update_person}) do
    IO.puts "Update or create person"
    # get user from index with id
    # mark user as deleted "deleted" => true
    # update index
    # update db
  end

  def execute_action(data, {:add_name, name_data}) do
    IO.puts "Adding name to user"
    names = Map.get(data, "names", [])
    new_names = List.insert_at(names, 0, name_data)
    Map.put(data, "names", new_names)
    |> IO.inspect()
    # IO.inspect(name_data, label: "Name data")
  end


  # available actions
  # :delete_user
  # :add_name
  # :update_name
  # :add_department
  # :add_identifier
  # :aquire_gup_person_id


  # def execute_actions({:ok, primary_data, actions}) do
  #   Enum.each(actions, fn action ->
  #     execute_action(primary_data, action)
  #     |> log_transaction()
  #   end)
  # end

  # def execute_actions(primary_data, {}) do
  #   IO.puts "No actions to execute"
  # end

  # def execute_action(primary_data, {:error, error, error_log_data}) do
  #   IO.puts "Error: #{error}"
  #   IO.inspect error_log_data
  # end

  # def execute_action(primary_data, {:delete_user, id}) do
  #   IO.puts "Deleting user #{id}"
  #   # get user from index with id
  #   # mark user as deleted "deleted" => true
  #   # update index
  #   # update db
  # end

  # def execute_action(primary_data, {:add_name, name}) do
  #   IO.puts "Adding name #{name} to user #{primary_data}"
  #   name = Map.put(name, "primary", true)
  #   names =
  #     Map.get(primary_data, "names", [])
  #     |> set_primary_name_to_false()
  #     |> List.insert_at(0, name)

  #   primary_data = Map.put(primary_data, "names", names)

  #   # update index
  #   # update db
  # end

  # def execute_action(primary_data, {:update_name, name}) do
  #   IO.puts "Updating name to #{name} for user #{primary_data}"
  # end

  # def execute_action(primary_data, {:add_department, department}) do
  #   IO.puts "Adding department #{department} to user #{primary_data}"
  # end

  # def execute_action(primary_data, {:add_identifier, identifier}) do
  #   IO.puts "Adding identifier #{identifier} to user #{primary_data}"
  # end


  def set_primary_name_to_false(names) do
    Enum.map(names, fn name ->
      if name["primary"] do
        Map.put(name, "primary", false)
      else
        name
      end
    end)
  end



  def log_transaction(primary_data) do
    IO.puts "Logging transaction for user #{primary_data}"
  end



end
