defmodule GupIndexManager.Resource.Persons.Merger do
  def merge(person_input_data) do
    with {true, person_input_data} <- meets_the_minimum_person_requirements(person_input_data) do
      person_input_data
      # |> has_gup_admin_id()
      |> exists_in_index()
      |> colliding_identifiers()
      |> merge_person()

      # |> create_or_update_person()
    else
      {false, error_message} -> {:error, error_message}
    end
  end

  def has_gup_admin_id(person_input_data) do
    case Map.get(person_input_data, "id") do
      nil -> {false, person_input_data}
      _ -> {true, person_input_data}
    end
  end

  ############################################################################################################################
  #
  #   Check if the person input data meets the minimum requirements
  #
  ############################################################################################################################

  defp meets_the_minimum_person_requirements(person_input_data) do
    case person_input_data do
      %{"identifiers" => [%{"code" => "X_ACCOUNT"}]} ->
        {true, person_input_data}

      %{"identifiers" => [%{"code" => "SCOPUS"}]} ->
        {true, person_input_data}

      %{"identifiers" => [%{"code" => "ORCID"}]} ->
        {true, person_input_data}

      %{"names" => [%{"first_name" => _, "last_name" => _, "id" => _}]} ->
        {true, person_input_data}

      # gup admin internal id
      %{"id" => _} ->
        {true, person_input_data}

      _ ->
        {false, "The person_input_data does not meet the minimum requirements"}
    end
  end


  ############################################################################################################################
  #
  #   Check if the person exist in the index, if so return the existing data
  #   This may retun multiple hits from the index
  #
  ############################################################################################################################

  defp exists_in_index(person_input_data) do
    IO.puts("CHECK IF PERSON EXISTS IN INDEX")
    gup_person_id_matches = match_by_gup_person_id(person_input_data)
    identifier_matches = GupIndexManager.Resource.Index.Search.find_person_by_identifiers(person_input_data["identifiers"])
    |> elem(1)
    matches =
    [gup_person_id_matches | identifier_matches]
    |> List.flatten()
    |> Enum.uniq()

    {length(matches) > 0, person_input_data, remap_person_data(matches)}


  end

  def match_by_gup_person_id(person_input_data) do
    name = List.first(Map.get(person_input_data, "names", []))
    id = Map.get(name, "gup_person_id")
    IO.inspect(id, label: "GUP PERSON ID FROM INPUT DATA")
    case id do
      nil -> []
      _ ->
        case GupIndexManager.Resource.Index.Search.find_person_by_gup_id(id) do
          {false, _} -> []
          {true, existing_person_data} -> existing_person_data
        end
    end
  end


  ############################################################################################################################
  #
  #   Check if any of the identifiers ORCID and X_ACCOUNT exists in the index and does not collide with incomming data
  #
  ############################################################################################################################
  def colliding_identifiers({_person_exist_in_index = false, person_input_data}) do
    {false, person_input_data}
  end

  # one or more matching entries exists in the index
  def colliding_identifiers({_person_exist_in_index = true, person_input_data, existing_data}) do
    search_colliding_identifiers(person_input_data, existing_data)
    |> Enum.any?(fn c -> c == true end)
    |> case do
      true -> {:error, "Colliding ORCID and/or X_ACCOUNT"} # Pass data for logging
      false -> {person_input_data, existing_data}
    end
  end

  def search_colliding_identifiers(person_input_data, existing_data) do
    Enum.map(existing_data, fn existing_person ->
      existing_person_identifiers = Map.get(existing_person, "identifiers")
      incoming_person_identifiers = Map.get(person_input_data, "identifiers")
      colliding_orcid = has_colliding_orcid(incoming_person_identifiers, existing_person_identifiers)
      colliding_x_account = has_colliding_x_account(incoming_person_identifiers, existing_person_identifiers)
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
    incoming_x_account = Enum.find(person_input_identifiers, fn id -> id["code"] == "X_ACCOUNT" end)
    existing_x_account = Enum.find(existing_person_identifiers, fn id -> id["code"] == "X_ACCOUNT" end)
    compare_identifiers(incoming_x_account, existing_x_account)
  end

  def compare_identifiers(_any, nil), do: _colliding = false
  def compare_identifiers(nil, _any), do: _colliding = false
  def compare_identifiers(incoming, existing), do: _colliding = incoming["value"] != existing["value"]



  ############################################################################################################################
  #
  #   Merge person data: Person does not exist in index and should be processed as a new person
  #
  ############################################################################################################################
  def merge_person(_person_exixts_in_index = false, person_input_data) do
    IO.puts("Person DOES NOT EXIST IN INDEX, PASS THROUGH TO CREATE OR UPDATE")
    {:ok, person_input_data}
  end

  ############################################################################################################################
  #
  #   Merge person data: Person exist in index and one or more identifiers are colliding, generating an error. Abort processing
  #
  ############################################################################################################################

  def merge_person({:error, error_message}) do
    IO.puts("MERGE PERSON ERROR")
    {:error, error_message}
  end

  ############################################################################################################################
  #
  #   Merge person data: Person exist in index and no colliding identifiers, merge the data
  #
  ############################################################################################################################

  def merge_person({_exists_in_index = true, person_input_data, existing_data}) do

    # transactions = %{
    #   actions: []
    # }
    # [primary_existing_person_data | secondary_existing_data] = existing_data
    # primary_existing_person_data
    # |> merge_name_forms(secondary_existing_data, transactions)
    # IO.inspect(length(existing_data), label: "Number of existing persons")


  end

  def merge_name_forms(target_data, merge_data, transactions) do

  end

  def merge_identifiers(existing_person, person_input_data, actions) do
    existing_identifiers = Map.get(existing_person, "identifiers", [])
    new_identifiers = Map.get(person_input_data, "identifiers", [])
    new_actions =
      Enum.map(new_identifiers, fn new_identifier ->
        case identifier_exists(existing_identifiers, new_identifier) do
          false -> {:add_identifier, new_identifier}
          _ -> []
        end
      end)
    {:ok, existing_person, (actions ++ new_actions) |> List.flatten()}
  end

  def identifier_exists(existing_identifiers, new_identifier) do
    Enum.any?(existing_identifiers, fn existing_identifier ->
      existing_identifier["code"] == new_identifier["code"] and
        existing_identifier["value"] == new_identifier["value"]
    end)
  end

  def create_or_update_person({person_input_data, _existing_data, actions}) do
    IO.puts("CREATE OR UPDATE PERSON")
    actions = (actions ++ [{:create_or_update_person}]) |> List.flatten()
    {:ok, person_input_data, actions}
  end

  def create_or_update_person({:error, error_message}) do
    {:error, error_message}
  end


  def remap_person_data(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
  end
end
