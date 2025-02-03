defmodule GupAdmin.Resource.Person.PersonValidator do

  require Logger

  # Error codes

  @invalid_GUPADMIN_ID           "INVALID_GUPADMIN_ID"
  @invalid_UPDATED_AT            "INVALID_UPDATED_AT"
  @invalid_CREATED_AT            "INVALID_CREATED_AT"
  @invalid_YEAR_OF_BIRTH         "INVALID_YEAR_OF_BIRTH"

  @invalid_ID_X_ACCOUNT          "INVALID_ID_X_ACCOUNT"
  @invalid_ID_POP_ID             "INVALID_ID_POP_ID"
  @invalid_ID_CID                "INVALID_CID"
  @invalid_ID_ORCID              "INVALID_ID_ORCID"
  @invalid_ID_SCOPUS_AUTHOR_ID   "INVALID_ID_SCOPUS_AUTHOR_ID"
  @invalid_ID_WOS_RESEARCHER_ID  "INVALID_ID_WOS_RESEARCHER_ID"
  @invalid_ID_WOS_DAISNG_ID      "INVALID_ID_WOS_DAISNG_ID"

  @invalid_NAME_PRIMARY          "INVALID_NAME_PRIMARY"

  @invalid_NAME_START_DATE       "INVALID_NAME_START_DATE"
  @invalid_NAME_END_DATE         "INVALID_NAME_END_DATE"
  @invalid_NAME_GUP_PERSON_ID    "INVALID_NAME_GUP_PERSON_ID"
  @invalid_NAME_FIRST_NAME       "INVALID_NAME_FIRST_NAME"
  @invalid_NAME_LAST_NAME        "INVALID_NAME_LAST_NAME"

  @invalid_DEP_START_DATE        "INVALID_DEP_START_DATE"
  @invalid_DEP_END_DATE          "INVALID_DEP_END_DATE"
  @invalid_DEP_NAME              "INVALID_DEP_NAME"
  @invalid_DEP_GUP_DEP_ID        "INVALID_DEP_GUP_DEP_ID"
  @invalid_DEP_ORGDB_ID          "INVALID_DEP_ORGDB_ID"

  @invalid_DEP_HIER_ORG_NAME     "INVALID_DEP_HIER_ORG_NAME"
  @invalid_DEP_HIER_ORGNR        "INVALID_DEP_HIER_ORGNR"
  @invalid_DEP_HIER_ORGDB_ID     "INVALID_DEP_HIER_ORGDB_ID"
  @invalid_DEP_HIER_ORGTYPE_CODE "INVALID_DEP_HIER_ORGTYPE_CODE"
  @invalid_DEP_HIER_ORGTYPE_NAME "INVALID_DEP_HIER_ORGTYPE_NAME"


  # Regular expressions

  @regex_GUPADMIN_ID             ~r/^\d+$/           # TO DO

  @regex_ID_X_ACCOUNT            ~r/^x[a-z]{5}$/
  @regex_ID_POP_ID               ~r/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
  @regex_CID                     ~r/^.+$/            # TO DO
  @regex_ID_ORCID                ~r/^\d{4}-\d{4}-\d{4}-\d{3}[0-9X]$/
  @regex_ID_SCOPUS_AUTHOR_ID     ~r/^[0-9]+$/
  @regex_ID_WOS_RESEARCHER_ID    ~r/^[0-9]+$/
  @regex_ID_WOS_DAISNG_ID        ~r/^.+$/            # TO DO

  @regex_YEAR                    ~r/^(?:19|20)\d{2}$/
  @regex_DATE                    ~r/^\d{4}-\d{2}-\d{2}$/
  @regex_NAME                    ~r/^.+$/            # TO DO

  @regex_GUP_PERSON_ID           ~r/^\d+$/           # TO DO this will not be necessary as we check for integer in pattern.

  @regex_GUP_DEP_ID              ~r/^\d+$/           # TO DO

  @regex_DEP_HIER_ORGNR          ~r/^\d+$/
  @regex_DEP_HIER_ORGDB_ID       ~r/^OD-\d+-\d+$/
  @regex_DEP_HIER_ORGTYPE_CODE   ~r/^OT-\d+-\d+$/


  @doc """
  Validates a person map and returns a possibly empty list of error strings.
  """

  def validate(person) do
    case do_validate(person) do
      []     -> :ok
      errors -> {:error, Enum.reverse(errors)}
    end
  end

  defp do_validate(person) when is_map(person) do
    Logger.debug("Validating person: #{inspect(person)}")
    []
    #|> validate_id(person)
    #|> validate_updated_at(person)
    #|> validate_created_at(person)
    |> validate_year_of_birth(person)
    |> validate_identifiers(person)
    |> validate_names(person)
    #|> validate_departments(person)
  end
  defp do_validate(_person), do: {:error, ["ERROR_PERSON_NOT_A_MAP"]}

  # "id"

  defp validate_id(errors, %{"id" => id}) when is_integer(id) do
      errors
  end
  defp validate_id(errors, _person) do
    [@invalid_GUPADMIN_ID | errors]
  end

  # "updated_at" / "created_at"

  defp validate_iso8601(datetime, field_name) when is_binary(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, _dt, _offset} -> :ok
      {:error, _} -> {:error, "Field #{field_name} not an ISO8601 datetime"}
    end
  end

  defp validate_updated_at(errors, %{"updated_at" => datetime}) when is_binary(datetime) do
    case validate_iso8601(datetime, "updated_at") do
       :ok       -> errors
      {:error, _} -> [@invalid_UPDATED_AT | errors]
    end
  end
  defp validate_updated_at(errors, _person), do: errors

  defp validate_created_at(errors, %{"created_at" => datetime}) when is_binary(datetime) do
    case validate_iso8601(datetime, "created_at") do
       :ok       -> errors
      {:error, _} -> [@invalid_CREATED_AT | errors]
    end
  end
  defp validate_created_at(errors, _person), do: errors

  # "year_of_birth"

  defp validate_year_of_birth(errors, %{"year_of_birth" => year}) when is_integer(year) do
    if Regex.match?(@regex_YEAR, Integer.to_string(year)) do
      errors
    else
      [@invalid_YEAR_OF_BIRTH | errors]
    end
  end
  defp validate_year_of_birth(errors, _year_of_birth), do: [@invalid_YEAR_OF_BIRTH | errors]


  # -----------------------------------------------------------------------------------------------

  # "identifiers"

  defp validate_identifiers(errors, %{"identifiers" => identifiers}) when is_list(identifiers) do
    Enum.reduce(identifiers, errors, fn identifier, errs ->
      validate_identifier(errs, identifier)
    end)
  end
  defp validate_identifiers(errors, _person), do: ["ERROR_IDENTIFIERS" | errors]

  defp validate_identifier(errors, %{"code" => code, "value" => value}) do
    # Välj rätt valideringsfunktion baserat på code
    case code do
      "X_ACCOUNT"         -> validate_x_account(errors, value)
      "POP_ID"            -> validate_pop_id(errors, value)
      "CID"               -> validate_cid(errors, value)
      "ORCID"             -> validate_orcid(errors, value)
      "SCOPUS_AUTHOR_ID"  -> validate_scopus_author_id(errors, value)
      "WOS_RESEARCHER_ID" -> validate_wos_researcher_id(errors, value)
      "WOS_DAISNG_ID"     -> validate_wos_daisng_id(errors, value)
      _                   -> ["ERROR_UNKNOWN_IDENTIFICATION_CODE___#{code}" | errors]
    end
  end
  defp validate_identifier(errors, _), do: ["ERROR_IDENTIFIER" | errors]

  # Exempel på specifika identifier-valideringar
  defp validate_x_account(errors, value) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_ID_X_ACCOUNT, value) do
      errors
    else
      [@invalid_ID_X_ACCOUNT | errors]
    end
  end
  defp validate_x_account(errors, _), do: [@invalid_ID_X_ACCOUNT | errors]

  defp validate_pop_id(errors, value) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_ID_POP_ID, value) do
      errors
    else
      [@invalid_ID_POP_ID | errors]
    end
  end
  defp validate_pop_id(errors, _), do: [@invalid_ID_POP_ID | errors]

  defp validate_cid(errors, value) when is_binary(value) and byte_size(value) > 0 do
    # TO DO
    errors
  end
  defp validate_cid(errors, _), do: [@invalid_CID | errors]

  defp validate_orcid(errors, value) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_ID_ORCID, value) do
      errors
    else
      [@invalid_ID_ORCID | errors]
    end
  end
  defp validate_orcid(errors, _), do: [@invalid_ID_ORCID | errors]

  defp validate_scopus_author_id(errors, value) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_ID_SCOPUS_AUTHOR_ID, value) do
      errors
    else
      [@invalid_ID_SCOPUS_AUTHOR_ID | errors]
    end
  end
  defp validate_scopus_author_id(errors, _), do: [@invalid_ID_SCOPUS_AUTHOR_ID | errors]

  defp validate_wos_researcher_id(errors, value) when is_binary(value) and byte_size(value) > 0 do
    # TO DO
    errors
  end
  defp validate_wos_researcher_id(errors, _), do: [@invalid_ID_WOS_RESEARCHER_ID | errors]

  defp validate_wos_daisng_id(errors, value) when is_binary(value) and byte_size(value) > 0 do
    # TO DO
    errors
  end
  defp validate_wos_daisng_id(errors, _), do: [@invalid_ID_WOS_DAISNG_ID | errors]

  # -----------------------------------------------------------------------------------------------

  defp validate_names(errors, %{"names" => names}) when is_list(names) do
    Enum.reduce(names, errors, fn name, errs ->
      validate_name(errs, name)
    end)
  end
  defp validate_names(errors, _person), do: ["ERROR_NAMES" | errors]

  defp validate_name(errors, name) when is_map(name) do
    errors
    |> validate_name_primary(name)
    |> validate_name_start_date(name)
    |> validate_name_end_date(name)
    |> validate_name_gup_person_id(name)
    |> validate_name_first_name(name)
    |> validate_name_last_name(name)
  end
  defp validate_name(errors, _name), do: ["ERROR_NAME_NOT_AN_OBJECT" | errors]

  defp validate_name_primary(errors, %{"primary" => value}) when is_boolean(value), do: errors
  defp validate_name_primary(errors, %{"primary" => _invalid_value}), do: [@invalid_NAME_PRIMARY | errors]
  defp validate_name_primary(errors, _), do: errors

  defp validate_name_start_date(errors, %{"start_date" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DATE, value) do
      errors
    else
      [@invalid_NAME_START_DATE | errors]
    end
  end
  defp validate_name_start_date(errors, _), do: [@invalid_NAME_START_DATE | errors]

  defp validate_name_end_date(errors, %{"end_date" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DATE, value) do
      errors
    else
      [@invalid_NAME_END_DATE | errors]
    end
  end
  defp validate_name_end_date(errors, %{"end_date" => value}) when is_nil(value), do: errors
  defp validate_name_end_date(errors, _), do: [@invalid_NAME_END_DATE | errors]

  defp validate_name_gup_person_id(errors, %{"gup_person_id" => value}) when is_integer(value) do
      errors
  end
  defp validate_name_gup_person_id(errors, _), do: [@invalid_NAME_GUP_PERSON_ID | errors]

  defp validate_name_first_name(errors, %{"first_name" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_NAME, value) do
      errors
    else
      [@invalid_NAME_FIRST_NAME | errors]
    end
  end
  defp validate_name_first_name(errors, _), do: [@invalid_NAME_FIRST_NAME | errors]

  defp validate_name_last_name(errors, %{"last_name" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_NAME, value) do
      errors
    else
      [@invalid_NAME_LAST_NAME | errors]
    end
  end
  defp validate_name_last_name(errors, _), do: [@invalid_NAME_LAST_NAME | errors]

  # -----------------------

  defp validate_departments(errors, %{"departments" => names}) when is_list(names) do
    Enum.reduce(names, errors, fn name, errs ->
      validate_department(errs, name)
    end)
  end
  defp validate_departments(errors, _person), do: ["ERROR_DEPARTMENTS" | errors]

  defp validate_department(errors, department) when is_map(department) do
    errors
    |> validate_dep_start_date(department)
    |> validate_dep_end_date(department)
    |> validate_dep_name(department)
    |> validate_dep_gup_dep_id(department)
    |> validate_dep_orgdb_id(department)
    |> validate_dep_hierarchy(department)
  end
  defp validate_department(errors, _department), do: ["ERROR_DEPARTMENT_NOT_AN_OBJECT" | errors]

  defp validate_dep_start_date(errors, %{"start_date" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DATE, value) do
      errors
    else
      [@invalid_DEP_START_DATE | errors]
    end
  end
  defp validate_dep_start_date(errors, _), do: [@invalid_DEP_START_DATE | errors]

  defp validate_dep_end_date(errors, %{"end_date" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DATE, value) do
      errors
    else
      [@invalid_DEP_END_DATE | errors]
    end
  end
  defp validate_dep_end_date(errors, %{"end_date" => value}) when is_nil(value), do: errors
  defp validate_dep_end_date(errors, _), do: [@invalid_DEP_END_DATE | errors]

  defp validate_dep_name(errors, %{"name" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_NAME, value) do
      errors
    else
      [@invalid_DEP_NAME | errors]
    end
  end
  defp validate_dep_name(errors, _), do: [@invalid_DEP_NAME | errors]

  defp validate_dep_gup_dep_id(errors, %{"gup_department_id" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_GUP_DEP_ID, value) do
      errors
    else
      [@invalid_DEP_GUP_DEP_ID | errors]
    end
  end
  defp validate_dep_gup_dep_id(errors, _), do: [@invalid_DEP_GUP_DEP_ID | errors]

  defp validate_dep_orgdb_id(errors, %{"orgdb_id" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DEP_HIER_ORGDB_ID, value) do
      errors
    else
      [@invalid_DEP_ORGDB_ID | errors]
    end
  end
  defp validate_dep_orgdb_id(errors, _), do: [@invalid_DEP_ORGDB_ID | errors]
  # -----------------------------------------------------------------------------------------------

  defp validate_dep_hierarchy(errors, %{"hierarchy" => hierarchy}) when is_list(hierarchy) do
    Enum.reduce(hierarchy, errors, fn org, errs ->
      validate_dep_hier_org(errs, org)
    end)
  end
  defp validate_dep_hierarchy(errors, _hierarchy), do: ["ERROR_DEPARTMENT_HIERARCHY" | errors]

  defp validate_dep_hier_org(errors, org) when is_map(org) do
    errors
    |> validate_dep_hier_org_orgname(org)
    |> validate_dep_hier_org_orgnr(org)
    |> validate_dep_hier_org_orgdb_id(org)
    |> validate_dep_hier_org_orgtype_code(org)
    |> validate_dep_hier_org_orgtype_name(org)
  end
  defp validate_dep_hier_org(errors, _), do: ["ERROR_DEPARTMENT_HIERARCHY_ORG_NOT_AN_OBJECT" | errors]

  defp validate_dep_hier_org_orgname(errors, %{"orgname" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_NAME, value) do
      errors
    else
      [@invalid_DEP_HIER_ORG_NAME | errors]
    end
  end
  defp validate_dep_hier_org_orgname(errors, _), do: [@invalid_DEP_HIER_ORG_NAME | errors]

  defp validate_dep_hier_org_orgnr(errors, %{"orgnr" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DEP_HIER_ORGNR, value) do
      errors
    else
      [@invalid_DEP_HIER_ORGNR | errors]
    end
  end
  defp validate_dep_hier_org_orgnr(errors, _), do: [@invalid_DEP_HIER_ORGNR | errors]

  defp validate_dep_hier_org_orgdb_id(errors, %{"orgdb_id" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DEP_HIER_ORGDB_ID, value) do
      errors
    else
      [@invalid_DEP_HIER_ORGDB_ID | errors]
    end
  end
  defp validate_dep_hier_org_orgdb_id(errors, _), do: [@invalid_DEP_HIER_ORGDB_ID | errors]

  defp validate_dep_hier_org_orgtype_code(errors, %{"orgtype_code" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_DEP_HIER_ORGTYPE_CODE, value) do
      errors
    else
      [@invalid_DEP_HIER_ORGTYPE_CODE | errors]
    end
  end
  defp validate_dep_hier_org_orgtype_code(errors, _), do: [@invalid_DEP_HIER_ORGTYPE_CODE | errors]

  defp validate_dep_hier_org_orgtype_name(errors, %{"orgtype_name" => value}) when is_binary(value) and byte_size(value) > 0 do
    if Regex.match?(@regex_NAME, value) do
      errors
    else
      [@invalid_DEP_HIER_ORGTYPE_NAME | errors]
    end
  end
  defp validate_dep_hier_org_orgtype_name(errors, _), do: [@invalid_DEP_HIER_ORGTYPE_NAME | errors]

end
