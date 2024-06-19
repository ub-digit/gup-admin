defmodule GupIndexManager.Resource.Persons.Merger do
  def merge(person_input_data) when is_map(person_input_data) do
    with {true, person_input_data} <- meets_the_minimum_person_requirements(person_input_data) do
      person_input_data
      |> has_x_account()
      |> load_existing_person_data_with_x_account()
      |> colliding_identifiers()
      # |> has_orcid()
      # |> merge_person()
      # |> match_by_other_identifiers()
      # |> merge_person()
      # |> create_or_update_person()
    else
      {false, error_message} -> {:error, error_message}
    end
  end

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

      # gup admin interanal id
      %{"id" => _} ->
        {true, person_input_data}

      _ ->
        {false, "The person_input_data does not meet the minimum requirements"}
    end
  end

  defp has_x_account(person_input_data) do
    person_input_data["identifiers"]
    |> Enum.filter(fn id -> id["code"] == "X_ACCOUNT" end)
    |> case do
      [] -> {false, person_input_data}
      [x_account_data] -> {true, person_input_data, [x_account_data]}
    end
  end

  def has_orcid({_has_x_acount = false, person_input_data}) do
    person_input_data["identifiers"]
    |> Enum.filter(fn id -> id["code"] == "ORCID" end)
    |> case do
      [] -> {false, person_input_data}
      [orcid_data] -> {true, person_input_data, [orcid_data]}
    end

    {_has_x_acount = false, person_input_data}
  end

  def has_orcid({_has_x_account = true, person_input_data, existing_person_data}) do
    {_has_x_account = true, person_input_data, existing_person_data}
  end

  defp load_existing_person_data_with_x_account(
         {_has_x_account = true, person_input_data, x_account_data}
       ) do

    case GupIndexManager.Resource.Index.Search.find_person_by_identifiers(x_account_data) do
      {true, existing_person_data} ->
        {true, person_input_data, existing_person_data |> List.first() |> Map.get("_source")}

      {false, _} ->
        {false, person_input_data}
    end
  end

  defp load_existing_person_data_with_x_account({_has_x_account = false, person_input_data}) do
    IO.puts("PERSON DOES NOT HAVE AN X ACCOUNT")
    {false, person_input_data}
  end

  def match_by_other_identifiers({ok, person_input_data}) do
    IO.puts("MATCH BY OTHER IDENTIFIERS")
    {:ok, person_input_data}
  end

  defp merge_person({:error, error_message}) do
    {:error, error_message}
  end

  defp merge_person({_existing_data_found = true, person_input_data, existing_person_data}) do
    # IO.puts("MERGE PERSON --- WITH NEW DATA")
    # Perform actual merging of the person data
    {person_input_data, existing_person_data, []}
    |> merge_names()
    |> merge_identifiers()

    # |> merge_departments(person_input_data)
  end

  defp merge_person({_existing_data_found = false, person_input_data}) do
    # no existing data was found
    {:ok, person_input_data, []}
  end

  defp merge_names({person_input_data, existing_data, actions}) do
    # IO.puts("MERGE NAMES")
    existing_names = Map.get(existing_data, "names", [])
    new_names = Map.get(person_input_data, "names", [])

    new_actions =
      Enum.map(new_names, fn new_name ->
        case name_exists(existing_names, new_name) do
          false -> {:add_name, new_name}
          _ -> []
        end
      end)

    actions = (actions ++ new_actions) |> List.flatten()
    IO.inspect(actions, label: "ACTIONS AFTER")
    {person_input_data, existing_data, actions}
  end

  defp name_exists(existing_names, new_name) do
    Enum.any?(existing_names, fn existing_name ->
      existing_name["first_name"] == new_name["first_name"] and
        existing_name["last_name"] == new_name["last_name"] and
        existing_name["gup_person_id"] == new_name["gup_person_id"]
    end)
  end

  defp merge_identifiers({person_input_data, existing_data, actions}) do
    # IO.puts("MERGE IDENTIFIERS ----------------------")
    existing_identifiers = Map.get(existing_data, "identifiers", [])
    new_identifiers = Map.get(person_input_data, "identifiers", [])

    new_actions =
      Enum.map(new_identifiers, fn new_identifier ->
        case identifier_exists(existing_identifiers, new_identifier) do
          false -> {:add_identifier, new_identifier}
          _ -> []
        end
      end)
      |> IO.inspect(label: "Check for colliding ORCID's")

    {person_input_data, existing_data, (actions ++ new_actions) |> List.flatten()}
  end

  defp identifier_exists(existing_identifiers, new_identifier) do
    Enum.any?(existing_identifiers, fn existing_identifier ->
      existing_identifier["code"] == new_identifier["code"] and
        existing_identifier["value"] == new_identifier["value"]
    end)
  end

  def colliding_identifiers({false, person_input_data}) do
    IO.puts("NO COLLIDING IDENTIFIERS")
    {true, person_input_data, []}
  end

  def colliding_identifiers({true, person_input_data, existing_person_data}) do
    IO.puts("CHECK FOR COLLIDING IDENTIFIERS ->->->->_>_>")
    new_identifiers = Map.get(person_input_data, "identifiers", [])
    existing_identifiers = Map.get(existing_person_data, "identifiers", [])

    IO.inspect(new_identifiers, label: "NEW IDENTIFIERS")
    # new_orcids = Enum.filter(new_identifiers, fn id -> id["code"] == "ORCID" end)
    # existing_orcids = Enum.filter(existing_identifiers, fn id -> id["code"] == "ORCID" end)

    # case Enum.any?(new_orcids, fn new_orcid ->
    #        Enum.any?(existing_orcids, fn existing_orcid ->
    #          new_orcid["value"] == existing_orcid["value"]
    #        end)
    #      end) do
    #   true -> {:error, "Colliding ORCID's"}
    #   false -> {true, person_input_data, existing_person_data}
    # end
    {:error, "Colliding ORCID's"}
  end

  # When data reach this function it is ready to be indexed

  def create_or_update_person({person_input_data, existing_data, actions}) do
    IO.puts("CREATE OR UPDATE PERSON")

    actions = (actions ++ [{:create_or_update_person}]) |> List.flatten()

    {:ok, "person_input_data", actions}
  end

  def create_or_update_person({:error, error_message}) do
    {:error, error_message}
  end


  defp push_to_actions(actions, action, _data) do
    t = {:add_name, "data"}
    actions ++ [t]
    IO.inspect(actions, label: "actions BBBBBBBBBBBBBBBBBBBBBBBBBBB")
  end
end
