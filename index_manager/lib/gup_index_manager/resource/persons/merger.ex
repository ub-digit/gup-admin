defmodule GupIndexManager.Resource.Persons.Merger do
  ############################################################################################################################
  #
  #   Idea: Maybe put incomming data in a map after validating. Pattern match on the map in the functions...
  #
  #   Idea: if matching data length is 1 and data is exactly the same, bypass the merge.
  #
  #   If incomming data has an id (gup_admin_id) it's an exixsting person in gup-admin and should probably only be "saved" as is.
  #   (above might not be true, if the person has had new identifiers added)
  #
  ############################################################################################################################

  def merge(person_input_data) do
    with {true, person_input_data} <- meets_minimum_person_requirements(person_input_data) do
       person_input_data
       |> sanitize_data()
       |> exists_in_index()
       |> colliding_identifiers()
       |> input_data_has_gup_person_id()
       |> has_matching_gup_person_id()
       |> set_primary_and_secondary_data()
       |> merge_person()
       |> create_or_update_person()
       #TODO: move this outside of the pipe in order to run tests without commenting out below call

      # {"elem_0" => d |> elem(0), "elem_1" => d |> elem(1), "elem_2" => d |> elem(2), "elem_3" => d |> elem(3)}
       #%{"elem_0" => d |> elem(0), "elem_1" => d |> elem(1), "elem_2" => d |> elem(2)}
      # %{"elem_0" => d |> elem(0), "elem_1" => d |> elem(1)}
      #   %{"data" => d |> elem(0)}

    else
      # TODO: Log error and data

      {false, data} -> {:error, "The person_input_data does not meet the minimum requirements", data}
      # %{"merger" => "called"}
    end
  end

  ############################################################################################################################
  #
  #   Sanitize incomming data
  #
  ############################################################################################################################

  def sanitize_data(data) do
    %{
      "id" => Map.get(data, "id", nil),
      "names" => sanitize_names(Map.get(data, "names", [])),
      "departments" => Map.get(data, "departments", []),
      "identifiers" => Map.get(data, "identifiers", []),
      "year_of_birth" => get_year_of_birth(Map.get(data, "year_of_birth", nil)),
      "email" => Map.get(data, "email", nil),
      "deleted" => Map.get(data, "deleted", false),
      "is_merged" => Map.get(data, "is_merged", false),
      "force_primary_name" => Map.get(data, "force_primary_name", false)
    }
  end

  def get_year_of_birth(y_o_b) when is_bitstring(y_o_b), do: String.to_integer(y_o_b)
  def get_year_of_birth(y_o_b) when is_integer(y_o_b), do: y_o_b
  def get_year_of_birth(_), do: nil

  def sanitize_names(names) do
    # For now we assume that only one name consists in the input data
    # This may change if gup_admin will allow editing of persons
    # {primary_name, secondary_names} =
      names
     |> Enum.map(fn name ->
      %{
        "first_name" => Map.get(name, "first_name", ""),
        "last_name" => Map.get(name, "last_name", ""),
        "full_name" => "#{Map.get(name, "first_name", "")} #{Map.get(name, "last_name", "")}",
        "start_date" => Map.get(name, "start_date", nil),
        "end_date" => Map.get(name, "end_date", nil),
        "gup_person_id" => Map.get(name, "gup_person_id", nil),
        "primary" => false

      }
      end)
    # |> List.pop_at(0)

    #   primary_name = Map.put(primary_name, "primary", true)
    #   [primary_name | secondary_names] |> List.flatten()
#      |> IO.inspect(label: "SANITIZED NAMES")



    # |> set_primary_name()
  end

  # def set_primary_name(names) do
  #     {prim, rest} =
  #     names
  #     |> Enum.map(fn n -> Map.put(n, "primary", false) end)
  #     |> Enum.sort_by(fn x -> x["start_date"] end)
  #     |> List.pop_at(-1)

  #     prim = Map.put(prim, "primary", true)
  #     [prim | rest]
  #   end

  ############################################################################################################################
  #
  #   Check if the person input data meets the minimum requirements
  #
  ############################################################################################################################

  defp meets_minimum_person_requirements(person_input_data) do
    #IO.inspect(person_input_data, label: "MEETS MINIMUM PERSON REQUIREMENTS CHECK")


    # TODO: Move to validator module
    person_input_data
    |> has_gup_admin_id()
    |> is_valid_gup_name_form()
    |> has_identifiers()
    |> validate_requirements()
  end

  defp has_gup_admin_id(person_input_data) do
    id = Map.get(person_input_data, "id", nil)
    #IO.inspect(id, label: "GUP ADMIN ID FROM INPUT DATA")

    case id do
      nil -> {false, person_input_data}
      _ -> {true, person_input_data}
    end
  end
  defp is_valid_gup_name_form({_has_gup_admin_id = true, person_input_data}), do: {true, person_input_data}
  defp is_valid_gup_name_form({_has_gup_admin_id = false, person_input_data}) do
    names = Map.get(person_input_data, "names", [])
    valid = Enum.any?(names, fn name ->
      Map.has_key?(name, "first_name") && Map.has_key?(name, "last_name") &&
        Map.has_key?(name, "gup_person_id")
    end)
    {valid, person_input_data}
  end

  defp has_identifiers({_is_valid_gup_name_form = true, person_input_data}), do: {true, person_input_data}
  defp has_identifiers({_is_valid_gup_name_form = false, person_input_data}) do
    identifiers = Map.get(person_input_data, "identifiers", [])
    {length(identifiers) > 0, person_input_data}
  end

  defp validate_requirements({_has_identifiers = true, person_input_data}), do: {true, person_input_data}
  defp validate_requirements({_has_identifiers = false, person_input_data}), do: {false, person_input_data}


  def check_names(names) do
    Enum.any?(names, fn name ->
      Map.has_key?(name, "first_name") && Map.has_key?(name, "last_name") &&
        Map.has_key?(name, "gup_person_id")
    end)
  end

  ############################################################################################################################
  #
  #   Check if the person exist in the index, if so return the existing data
  #   This may retun multiple hits from the index
  #
  ############################################################################################################################

  defp exists_in_index(person_input_data) do
    #IO.puts("CHECK IF PERSON EXISTS IN INDEX")
    gup_admin_id_matches = match_by_gup_admin_id(person_input_data)
    #IO.inspect(gup_admin_id_matches, label: "GUP ADMIN ID MATCHES")
    gup_person_id_matches = match_by_gup_person_id(person_input_data)
   # IO.inspect(gup_person_id_matches, label: "GUP PERSON ID MATCHES")

    identifier_matches =
      GupIndexManager.Resource.Index.Search.find_person_by_identifiers(
        person_input_data["identifiers"]
      )
      |> elem(1)

    #IO.inspect(identifier_matches, label: "IDENTIFIER MATCHES")

    matches =
      (gup_person_id_matches ++ identifier_matches ++ gup_admin_id_matches)
      |> List.flatten()
      |> Enum.uniq()

      # |> IO.inspect(label: "MATCHES ->->->__>_>>>>>")

    remapped = remap_person_data(matches)
    # |> IO.inspect(label: "REMAPPPED matches")
    |> remove_primary_names()
    |> Enum.uniq()
 #   IO.inspect(remapped, label: "REMAPPPED matches")
    {length(remapped) > 0, person_input_data, remapped}
  end

  def match_by_gup_person_id(person_input_data) do
    name = List.first(Map.get(person_input_data, "names", []))
    id = Map.get(name, "gup_person_id")
   # IO.inspect(id, label: "GUP PERSON ID FROM INPUT DATA")

    case id do
      nil ->
        []

      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_id(id) do
          {false, _} -> []
          {true, existing_person_data} -> existing_person_data
        end
    end
  end

  def match_by_gup_admin_id(person_input_data) do
    id = Map.get(person_input_data, "id", nil)
    #IO.inspect(id, label: "GUP ADMIN ID FROM INPUT DATA")

    case id do
      nil ->
        []

      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_admin_id(id) do
          {false, _} -> []
          {true, existing_person_data} -> existing_person_data
        end
    end
  end

  def remove_primary_names(data) do
    Enum.map(data, fn person ->
      names = Map.get(person, "names", [])
      |> Enum.map(fn name -> Map.put(name, "primary", false) end)
      Map.put(person, "names", names)
    end)
  end

  ############################################################################################################################
  #
  #  Person does not exist in the index, pass through to check if it has a gup_person_id
  #
  ############################################################################################################################

  def colliding_identifiers({_person_exist_in_index = false, person_input_data, []}) do
    #IO.puts("Person DOES NOT EXIST IN INDEX, PASS THROUGH TO CREATE OR UPDATE")
    {:ok, person_input_data}
  end

  ############################################################################################################################
  #
  # one or more matching entries exists in the index. Send existing data and person input data to check for colliding identifiers
  #
  ############################################################################################################################

  def colliding_identifiers({_person_exist_in_index = true, person_input_data, existing_data}) do
    IO.puts("Person EXISTS IN INDEX, CHECK FOR COLLIDING IDENTIFIERS")

    search_colliding_identifiers(person_input_data, existing_data)
    |> Enum.any?(fn colliding -> colliding == true end)
    |> case do
      # Pass data for logging
      true -> {:error, "Colliding ORCID and/or X_ACCOUNT", {person_input_data, existing_data}}
      false -> {false, person_input_data, existing_data}
    end
  end

  # Passthrough error
  def has_matching_gup_person_id({:error, error_message, error_data}), do: {:error, error_message, error_data}
  # Passthrough ok - does not exist in index
  def has_matching_gup_person_id({:ok, person_input_data}), do: {:ok, person_input_data}

  def has_matching_gup_person_id({_has_gup_person_id = false, person_input_data, existing_data}),
    do: {false, person_input_data, existing_data}; IO.puts("NO MATCHING GUP PERSON ID")

  def has_matching_gup_person_id({_has_gup_person_id = true, gup_person_id, person_input_data, existing_data}) do
    # Check if person input data has a gup_person_id in the name that exists in the existing data

    is_existing_id =
      Enum.any?(existing_data, fn existing_person ->
        Enum.any?(Map.get(existing_person, "names", []), fn existing_name ->
          Map.get(existing_name, "gup_person_id") == gup_person_id
        end)
      end)

   # IO.inspect(is_existing_id, label: "IS EXISTING GUP PERSON ID")

    case is_existing_id do
      true -> {true, gup_person_id, person_input_data, existing_data}
      false -> {false, person_input_data, existing_data}
    end
  end

  def search_colliding_identifiers(person_input_data, existing_data) do
    Enum.map(existing_data, fn existing_person ->
      existing_person_identifiers = Map.get(existing_person, "identifiers")
      incoming_person_identifiers = Map.get(person_input_data, "identifiers")

      colliding_orcid =
        has_colliding_orcid(incoming_person_identifiers, existing_person_identifiers)

      colliding_x_account =
        has_colliding_x_account(incoming_person_identifiers, existing_person_identifiers)

      [colliding_orcid, colliding_x_account]
    end)
    |> List.flatten()
  end

  def has_colliding_orcid(person_input_identifiers, existing_person_identifiers) do
    incoming_orcid = Enum.find(person_input_identifiers, fn id -> id["code"] == "ORCID" end)
    existing_orcid = Enum.find(existing_person_identifiers, fn id -> id["code"] == "ORCID" end)
    compare_identifiers(incoming_orcid, existing_orcid)
  end

  def has_colliding_x_account(person_input_identifiers, existing_person_identifiers) do
    incoming_x_account =
      Enum.find(person_input_identifiers, fn id -> id["code"] == "X_ACCOUNT" end)

    existing_x_account =
      Enum.find(existing_person_identifiers, fn id -> id["code"] == "X_ACCOUNT" end)

    compare_identifiers(incoming_x_account, existing_x_account)
  end

  def compare_identifiers(_any, nil), do: _colliding = false
  def compare_identifiers(nil, _any), do: _colliding = false

  def compare_identifiers(incoming, existing),
    do: _colliding = incoming["value"] != existing["value"]

  ############################################################################################################################
  #
  #   Check if the person input data has a gup_person_id
  #
  ############################################################################################################################
  # incommingdata
  def input_data_has_gup_person_id({_colliding_identifiers = false, person_input_data, existing_data}) do
    # person exists in index
    # no colliding identifiers
    # check if person input data has a gup_person_id
    name = List.first(Map.get(person_input_data, "names", []))
    gup_person_id = Map.get(name, "gup_person_id", nil)
    #IO.inspect(gup_person_id, label: "INPUT DATA HAS GUP PERSON ID")

    case gup_person_id do
      nil -> {false, person_input_data, existing_data}
      _ -> {true, gup_person_id, person_input_data, existing_data}
    end
  end

  ############################################################################################################################
  #
  #  input_data_has_gup_person_id called with :ok, person_input_data and input data should have been caught by the previous function
  #
  ############################################################################################################################
  def input_data_has_gup_person_id({:ok, person_input_data}), do: {:ok, person_input_data}
  def input_data_has_gup_person_id({:error, error_message, error_data}), do: {:error, error_message, error_data}

  ############################################################################################################################
  #
  #   Set primary and secondary data (primary is the data set that will be kept as
  #  current data, secondary data will be merged into primary data and then marked as deleted)
  #
  ############################################################################################################################

  def set_primary_and_secondary_data({_has_matching_gup_person_id = false, %{"id" => id} = person_input_data, existing_data}) when not is_nil(id) do
  # IO.inspect(id, label: "ID IN SET PRIMARY AND SECONDARY DATA WITH EXISTING GUP ADMIN ID")
    # Dont mind this for now
    # WILL NEVER HAPPEN AS IF ID EXISTS IN INPUT DATA INPUT DATA SHOULD BE PASSED THROUGH TO CREATE OR UPDATE DIRECTLY
    # input data has a gup_admin_id and should be kept as primary data, and merged with existing data (i.e this data has originated from gup-admin)
    {:ok, {person_input_data, existing_data}}
  end

  def set_primary_and_secondary_data({_has_matching_gup_person_id = false, person_input_data, existing_data}) do
    # IO.puts(" # incomming data has a gup person id that does not match any existing gup person id")
    # incomming data has a gup person id that does not match any existing gup person id
    # There is exixting data in the index
    # set first exixting data as primary
    # add incomming data as secondary
    primary_data = hd(existing_data)
    secondary_data = (tl(existing_data) ++ [person_input_data]) |> List.flatten() |> Enum.uniq()
    {:ok, primary_data, secondary_data, person_input_data}
  end

  # The incomming data has a gup_person_id that matches an existing gup_person_id
  def set_primary_and_secondary_data({_has_matching_gup_person_id = true, gup_person_id, person_input_data, existing_data}) do


    # person exists in index
    # no colliding identifiers
    # person input data has a gup_person_id that matches an existing gup_person_id
    # set the existing data as primary and add the person input data to existing data as secondary

    {primary_data, secondary_data} =
      Enum.split_with(existing_data, fn existing_person ->
        #Map.get(List.first(Map.get(existing_person, "names", [])), "gup_person_id") == gup_person_id
        Enum.any?(Map.get(existing_person, "names", []), fn name -> Map.get(name, "gup_person_id") == gup_person_id end)

      end)
      # |> IO.inspect(label: "SPLIT WITH")

    primary_data = List.first(primary_data)


    secondary_data = secondary_data ++ [person_input_data]


    # IO.inspect(primary_data, label: "HELLLLLOOOO")
    {:ok, primary_data, secondary_data, person_input_data}
  end

  # no existing data, pass through to create_or_update
  def set_primary_and_secondary_data({:ok, person_input_data}), do: {:ok, person_input_data}
  # error detected in earlier stage, pass through
  def set_primary_and_secondary_data({:error, error_message, error_data}), do: {:error, error_message, error_data}

  def get_aggregated_names(existing_data) do
    Enum.reduce(existing_data, [], fn existing_person, acc ->
      Enum.reduce(Map.get(existing_person, "names", []), acc, fn name, acc ->
        [name | acc]
      end)
    end)
    |> List.flatten()
  end
  def merge_person({:ok, data}) do
     #IO.inspect("MERGE PERSON no secondary data")
    # IO.inspect(data, label: "DATA")
    {:ok, data}
  end

  def merge_person({:error, error_msg, error_data}) do
    # IO.inspect("MERGE PERSON ERROR")
    {:error, error_msg, error_data}
  end

  def merge_person({:ok, primary_data, secondary_data, person_input_data}) do
    # IO.inspect("MERGE PERSON----------------------")
    # IO.inspect(secondary_data, label: "SECONDARY DATA")

    actions = merge_names(primary_data, secondary_data, person_input_data)
      |> merge_year_of_birth(primary_data, secondary_data, person_input_data)
      |> merge_departments(primary_data, secondary_data, person_input_data)
      |> merge_identifiers(primary_data, secondary_data)
      # |> merge_year_of_birth(primary_data, secondary_data)
      |> delete_secondary_data(secondary_data, primary_data)
      # TODO: merge departments

    case length(actions) do
      # No actions needed
      0 -> {:ok, person_input_data, :no_actions}
      # Actions needed
      _ -> {:ok, primary_data, actions}
    end
  end

  def delete_secondary_data(actions, secondary_data, primary_data) do
  #  IO.inspect(secondary_data, label: "DELETE SECONDARY DATA")
  #  IO.inspect(primary_data, label: "DELETE SECONDARY DATA primary data")
    primary_data_id = Map.get(primary_data, "id", nil)
    new_actions = Enum.map(secondary_data, fn secondary_person ->
      id = Map.get(secondary_person, "id")
      case id do
        nil -> []
        id ->
          case primary_data_id == id do
            true -> []
            _ -> {:delete_person, id}
          end
      end
    end)
    # IO.inspect(new_actions, label: "NEW ACTIONS")
    actions ++ new_actions
    |> List.flatten()
  end

  # TODO: needs rewrite to make code more readable. Split into smaller functions
  def merge_names(primary_data, secondary_data, person_input_data) do
    #  IO.inspect(primary_data, label: "PRIMARY DATA")
    #  IO.inspect(secondary_data, label: "Secondary DATA")
    # merge the names from secondary data into primary data
    # if a name form in secondary data has the same gup_person_id as a name form in primary data, update first_name and last_name in primary data
    # if a name form in secondary data does not exist in primary data, add it to primary data
    # if a name form in secondary data does not have a gup_person_id that exists in primary data, acquire a new gup_person_id from gup

    primary_names = Map.get(primary_data, "names", [])
    # |> IO.inspect(label: "PRIMARY NAMES")
    secondary_names = get_aggregated_names(secondary_data)
    |> Enum.filter(fn name ->
      is_existing_name_form(primary_names, name) == false
    end)  # remove existing names from secondary data to avoid duplicates
    # check if the new/existing names have a gup_person_id
    name_actions = Enum.map(secondary_names, fn secondary_name ->
      Enum.any?(primary_names, fn primary_name ->
        primary_name["gup_person_id"] == secondary_name["gup_person_id"]
      end)
      |> case do
        true ->
          IO.puts("primary name has the same gup_person_id as secondary name" )
          {:update_name, secondary_name} # update first_name and last_name and dates, names has the same gup_person_id
        false ->
          # check if first_name and last_name are EXACTLY the same as in primary data
          # if so, do nothing
          # else acquire a new gup_person_id
          Enum.any?(primary_names, fn primary_name ->
            secondary_name["first_name"] == primary_name["first_name"] and
            secondary_name["last_name"] == primary_name["last_name"] and
            Map.get(secondary_name, "gup_person_id", nil) == nil
          end)
          |> case do
            true ->
              IO.inspect("update name form dates")
              update_name_form_dates(primary_names, secondary_name)
            false ->
              IO.inspect("needs new gup person id")
              needs_new_gup_person_id(secondary_name)
          end
      end
    end)
    |> List.flatten()

    force = Map.get(person_input_data, "force_primary_name", true)
    case force do
      true ->
        force_set_primary_name(name_actions, person_input_data)
      _ -> name_actions
    end
    # |> IO.inspect(label: "NAME ACTIONS")
  end    # TODO: later check if the name has a primary

  def force_set_primary_name(name_actions, person_input_data) do
    input_name = List.first(Map.get(person_input_data, "names", []))

    name_actions
    |> Enum.map(fn name_action ->
      name = elem(name_action, 1)
      action = elem(name_action, 0)
      same_name =
        name["first_name"] == input_name["first_name"] and
        name["last_name"] == input_name["last_name"]
        case same_name do
          false -> name_action
          true -> case action do
            :add_name -> {:add_name, Map.put(name, "primary", true)}
            :update_name -> {:update_name,  Map.put(name, "primary", true), elem(name_action, 2)}
            :acquire_gup_id -> {:acquire_gup_id, Map.put(name, "primary", true)}
          end
        end
    end)
  end

  def merge_departments(actions, primary_data, secondary_data, person_input_data) do
    input_deps = Map.get(person_input_data, "departments", [])
    primary_deps = Map.get(primary_data, "departments", [])
    secondary_deps = Enum.map(secondary_data, fn secondary_person -> Map.get(secondary_person, "departments", []) end) |> List.flatten() |> Enum.uniq()

    new_deps = case length(input_deps) > 0 do
      true -> input_deps
      false -> case length(primary_deps) > length(secondary_deps) do
        true -> primary_deps
        false -> secondary_deps
      end

    end

    case length(new_deps) do
      0 -> actions
      _ -> actions ++ [{:update_departments, new_deps}]
    end

  end

  def update_name_form_dates(primary_names, secondary_name) do
    #TODO: check if dates are the same, if not update

    Enum.filter(primary_names, fn primary_name ->
        primary_name["first_name"] == secondary_name["first_name"] and
        primary_name["last_name"] == secondary_name["last_name"]
    end)
    |> Enum.map(fn name ->
      {:update_name, secondary_name, name["gup_person_id"]}
    end)
  end

  defp needs_new_gup_person_id(secondary_name) do
    secondary_name
    |> Map.get("gup_person_id", nil)
    |> IO.inspect(label: "NEEDS NEW GUP PERSON ID?")
    |> case do
      nil -> {:acquire_gup_id, secondary_name}
      _ -> {:add_name, secondary_name}
    end
  end

  def is_existing_name_form(existing_names, input_name) do
    Enum.any?(existing_names, fn existing_name ->
        existing_name["first_name"] == input_name["first_name"] and
        existing_name["last_name"] == input_name["last_name"] and
        existing_name["gup_person_id"] == input_name["gup_person_id"]
    end)
    # |> IO.inspect(label: "IS EXISTING NAME FORM")
  end

  def merge_identifiers(actions, primary_data, secondary_data) do
    existing_identifiers = Map.get(primary_data, "identifiers", [])

    # for each person in secondary data, check if the identifier exists in primary data
    # if not add :add_identifier action to actions
    new_actions = Enum.map(secondary_data, fn secondary_person ->
      secondary_identifiers = Map.get(secondary_person, "identifiers", [])
      Enum.map(secondary_identifiers, fn secondary_identifier ->
        identifier_exists(existing_identifiers, secondary_identifier)
        |> case do
          true -> []
          false -> {:add_identifier, secondary_identifier}
        end
      end)
    end)
    actions ++ new_actions |> List.flatten() |> Enum.uniq()
  end

  def identifier_exists(existing_identifiers, new_identifier) do
    # IO.inspect(existing_identifiers, label: "EXISTING IDENTIFIERS")
    # IO.inspect(new_identifier, label: "NEW IDENTIFIER")
    Enum.any?(existing_identifiers, fn existing_identifier ->
      existing_identifier["code"] == new_identifier["code"] and
        existing_identifier["value"] == new_identifier["value"]
    end)
  end

  def merge_year_of_birth(actions, primary_data, secondary_data, incoming_person_data) do
    primary_year_of_birth = Map.get(primary_data, "year_of_birth", nil)
    secondary_years_of_birth = Enum.map(secondary_data, fn secondary_person -> Map.get(secondary_person, "year_of_birth", nil) end)
    incoming_year_of_birth = Map.get(incoming_person_data, "year_of_birth", nil)
    yob = case incoming_year_of_birth do
      nil -> primary_year_of_birth || get_secondary_year_of_birth(secondary_years_of_birth)
      _ -> incoming_year_of_birth
    end
    case yob do
      nil -> actions
      year_of_birth ->
        actions ++ [{:update_year_of_birth, year_of_birth}]
    end

  end

  def get_secondary_year_of_birth(secondary_years_of_birth) do
    Enum.filter(secondary_years_of_birth, fn yob -> yob != nil end)
    |> List.first()
  end

  def set_primary_name({:ok, primary_data, :no_actions}) do
    #IO.inspect("SET PRIMARY NAME with {:ok, primary_data, :no_actions}")
    {:ok, primary_data, :no_actions}
  end
  def set_primary_name({:ok, primary_data, actions}, input_data) do
    case has_name_updates(actions) do
      true -> actions ++ {:ok, primary_data, actions ++ [{:set_primary_name, input_data}] |> List.flatten()}
      _ -> {:ok, primary_data, actions}
    end
    # actions = actions ++ [{:set_primary_name, input_data}] |> List.flatten()
    # {:ok, primary_data, actions}
  end

  def set_primary_name({:error, error_message, error_data}, _input_data), do: {:error, error_message, error_data}
  def set_primary_name({:ok, primary_data}, input_data) do
    #IO.inspect("SET PRIMARY NAME with {:ok, primary_data}")
    {:ok, primary_data, [{:set_primary_name, input_data}]}
  end

  def has_name_updates(actions) do
    Enum.any?(actions, fn action -> elem(action, 0) == :update_name or elem(action, 0) == :add_name or elem(action, 0) == :acquire_gup_id end)
    #|> IO.inspect(label: "HAS NAME UPDATES")
  end

  # def set_primary_name({:error, error_message, error_data}, _person_input_data), do: {:error, error_message, error_data}
  # def set_primary_name({:ok, primary_data, :no_actions}, _person_input_data_raw) do
  #   IO.inspect("SET PRIMARY NAME NO ACTIONS!!!!!!")
  #   {:ok, primary_data, :no_actions}
  # end

  # def set_primary_name({:ok, person_data, actions}, person_input_data) do
  #   IO.inspect(actions, label: "SET PRIMARY NAME")
  #   primary_name = get_primary_name(person_input_data)
  #   actions = actions ++ [{:set_primary_name, primary_name}] |> List.flatten()


  #   {:ok, person_input_data, actions}
  # end

  # def set_primary_name({:ok, person_input_data}, _person_input_data_raw) do
  #   IO.puts("SET PRIMARY NAME")
  #   ({:ok, person_input_data})

  # end

  # def set_primary_name(names) do

  # end

  # def get_primary_name(names) do
  #   case length(names) > 1 do
  #     true -> get_newest_name(names)
  #     false -> List.first(names) |> Map.put("primary", true)
  #   end
  # end

  # def set_primary_name(names) do
  #   names
  #   |> Enum.map(fn n -> Map.put(n, "primary", false) end)
  #   Enum.sort_by(names, fn x -> x["start_date"] end)
  #   |> List.last() |> Map.put("primary", true)
  # end

  # def merge_year_of_birth(primary_data, secondary_data) do
  #   primary_year_of_birth = Map.get(primary_data, "year_of_birth", nil)
  #   secondary_years_of_birth = Enum.map(secondary_data, fn secondary_person -> Map.get(secondary_person, "year_of_birth", nil) end)
  # end

  def set_is_merged({:ok, person_input_data}), do: {:ok, person_input_data}
  def set_is_merged({:error, error_message, error_data}), do: {:error, error_message, error_data}
  def set_is_merged({:ok, primary_data, :no_actions}), do: ({:ok, primary_data, :no_actions})
  def set_is_merged({:ok, primary_data, actions}) do
    is_merged = Map.get(primary_data, "names", []) |> length() > 1
    primary_data = Map.put(primary_data, "is_merged", is_merged)
    {:ok, primary_data, actions}
  end

  def create_or_update_person({:ok, primary_data, :no_actions}) do
    IO.puts("CREATE OR UPDATE existing PERSON with no actions")
   {:ok, primary_data, :no_actions}
 end

  def create_or_update_person({:ok, primary_data, actions}) do
     #IO.puts("CREATE OR UPDATE PERSON with actions")
    {:ok, primary_data, actions ++ [{:create_or_update_person}] |> List.flatten()}
  end


  # TODO: Supply data for logging

  def create_or_update_person({:error, error_message, error_data}) do
    # IO.puts("CREATE OR UPDATE PERSON ERROR")
    {:error, error_message, error_data}
  end

  def create_or_update_person({:ok, person_input_data}) do
    # This is a new person that does not exist in the index
    IO.puts("CREATE OR UPDATE NEW PERSON")
    {actions, person_input_data} = check_name_forms_for_gup_person_id(person_input_data)

    {:ok, person_input_data, actions ++ [{:create_or_update_person}] |> List.flatten()}
  end

  def check_name_forms_for_gup_person_id(person_input_data) do
    names = Map.get(person_input_data, "names", [])
    actions = Enum.reduce(names, [], fn name, acc ->
        case Map.get(name, "gup_person_id", nil) do
          nil ->
            acc ++ [{:acquire_gup_id, name}]
          _ -> acc
        end
      end)
      |> List.flatten()
      |> Enum.uniq()

      new_names = Enum.map(names, fn name ->
        case Map.get(name, "gup_person_id", nil) do
          nil -> nil
          _ -> name
        end
      end)
      |> Enum.filter(fn name -> name != nil end)

      {actions, Map.put(person_input_data, "names", new_names)}

  end

  def remap_person_data(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
    |> Enum.filter(fn person -> Map.get(person, "deleted", false) == false end)
  end
end
