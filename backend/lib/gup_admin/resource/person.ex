defmodule GupAdmin.Resource.Person do
  alias Hex.HTTP
  alias GupAdmin.Resource.Person.PersonValidator
  alias GupAdmin.Resource.Search
  alias Elastix, as: SE

  require Logger

  ################################
  # Vocabulary
  # BE/be = backend (Gup Admin backend)
  # IM/im = index manager
  # SE/se = search engine (Elasticsearch)

  @im_merge_endpoint     "/persons"
  @im_endpoint           "/api/persons"
  @index_name            "persons"
  @send_and_receive_json [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
  @receive_json          [                                      {"Accept", "application/json"}]

  def im_base_url do
    default = "http://index-manager-backend:4000"
    System.get_env("GUP_INDEX_MANAGER_URL") || default
  end

  def im_api_key do
    default = ""
    System.get_env("GUP_INDEX_MANAGER_API_KEY") || default
  end

  def se_base_url do
    default = "http://elasticsearch:9200"
    System.get_env("ELASTICSEARCH_URL") || default
  end

# -------------------- GET FROM ENVIRONMENT VARIABLES --------------------------

  def id_codes do
    default = "X_ACCOUNT,POP_ID,CID,ORCID,SCOPUS_AUTHOR_ID,WOS_RESEARCHER_ID,WOS_DAISNG_ID"
    System.get_env("VALID_PERSON_IDENTIFICATION_CODES") || default
  end

  def id_codes_to_exclude do
    default = ""
    exclude = System.get_env("EXCLUDE_PERSON_IDENTIFICATION_CODES") || default
    Logger.debug("BE:R.id_codes_to_exclude: id_codes_to_exclude: #{exclude}")
    exclude
    |> String.split(",")
    |> Enum.map(&String.trim/1)

  end

  def create_id_codes_map(id_codes) when is_binary(id_codes) do

    id_codes
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(fn code -> code in id_codes_to_exclude() end)
    |> then(fn codes -> %{id_codes: codes} end)
  end

  def get_id_codes do
    Logger.debug("BE:R.get_id_codes: id_codes: #{id_codes()}")
    {:ok, %{id_codes: %{status_code: 200,
                        body:        create_id_codes_map(id_codes())}}}
  end

  # -------------------- WRITE THROUGH INDEX MANAGER ---------------------------

  # To IM: POST /persons [CREATE]
  def create(person_data_as_map) do
    Logger.debug("BE:R.create: person_data_as_map: #{inspect(person_data_as_map)}")
    case PersonValidator.validate(person_data_as_map) do
       :ok -> map2json(%{data: person_data_as_map})
              |> do_create()
      {:error, validation_error_list} -> {:error, %{errors: %{fe_validation: validation_error_list},
                                                    data:   person_data_as_map}}
    end
  end

  defp do_create({:ok, body}) do
    handle_request_to_im(:post, "#{@im_endpoint}", [201, 200], headers: @send_and_receive_json,
                                                               body:    body)
  end
  defp do_create({:error, error_message}, _id) do
    {:error, map2json_error_map(error_message)}
  end

  # To IM: PUT /persons/:id [UPDATE]
  def update(id, person_data_as_map) do
    Logger.debug("BE:R.update: person_data_as_map: #{inspect(person_data_as_map)}")
    case PersonValidator.validate(person_data_as_map) do
       :ok -> map2json(%{data: person_data_as_map})
              |> do_update(id)
      {:error, validation_error_list} -> {:error, %{errors: %{fe_validation: validation_error_list},
                                                    data:   person_data_as_map}}
    end
  end
  defp do_update({:ok, body}, id) do
    r = handle_request_to_im(:put, "#{@im_endpoint}/#{id}", [200], headers: @send_and_receive_json,
                                                               body:    body)
     map = elem(r, 1)
     f = elem(r, 0)
     merge_id = try_merge_gup_admin_person(id)

     new_id = case merge_id do
       :not_found -> id
       :nothing_to_do -> id
       _ -> merge_id
     end

    #  body = Map.get(map, :success) |> Map.get(:body) #|> Map.put("id", id)
    # response = {f, %{success: %{body: body,  status_code: 200}}}
    # # rr = {f, map |> put_in([:success, :body], "id", id)}
    # IO.inspect(r == response, label: "RESPONSE EQUALS EXPECTED RESPONSE XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx")
    resp = {f, map |> Map.put(:id, new_id) }
    IO.inspect(resp, label: "RESPONSE WITH ID XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     ")
    resp

  end
  defp do_update({:error, error_message}, _id) do
    {:error, map2json_error_map(error_message)}
  end

  # To IM: DELETE /persons/:id [DELETE]
  def delete(id) do
    Logger.debug("BE:R.delete: id: #{inspect(id)}")
    handle_request_to_im(:delete, "#{@im_endpoint}/#{id}", [200], headers: @receive_json)
  end

  # -------------------- READ DIRECTLY FROM SEARCH ENGINE  ---------------------

  # To SE: GET /persons/:id [GET THE ONE WITH THE ID]
  def get(id) do
    doc_id = id
    result = handle_request_to_se(:get, doc_id, nil, [200])
    Logger.debug("BE:R.get: result: #{inspect(result)}")
    result
  end

  # -------------------- WRITE THROUGH INDEX MANAGER ---------------------------

  defp handle_request_to_im(method, endpoint, expected_status_codes, opts \\ []) do
    url     = build_im_url(endpoint, Keyword.get(opts, :query_params, %{}))
    Logger.debug("BE:R.handle_request_to_im: method: #{method}, url: #{url}, expected_status_codes: #{inspect(expected_status_codes)}")
    headers = Keyword.get(opts, :headers, [])
    body    = Keyword.get(opts, :body, "")
    send_request_to_im(method, url, headers, body)
    |> digest_response_from_im(expected_status_codes)
  end

  defp build_im_url(path, maybe_query_params \\ %{}) do
    query_params = Map.put(maybe_query_params, "api_key", im_api_key())
    im_base_url()
    |> URI.merge(path)
    |> Map.put(:query, URI.encode_query(query_params))
    |> URI.to_string()
  end

  defp send_request_to_im(method, url, headers, body) do
    Logger.debug("BE:R.send_request_to_im: method: #{method}, url: #{url}")
    options = [recv_timeout: 5000, timeout: 5000] # Change these values as needed
    case method do
      :post   -> HTTPoison.post(url, body, headers, options)
      :put    -> HTTPoison.put(url, body, headers, options)
      :delete -> HTTPoison.delete(url, headers, options)
    end
  end

  # --------------------- DIGEST AND TRANSFORM RESPONSE_FROM IM ----------------

  defp digest_response_from_im({:ok, %HTTPoison.Response{status_code: status_code_from_im,
                                                         body:        body_string_from_im}},
                               expected_status_codes) do
    Logger.debug("BE:R.digest_response_from_im: status_code_from_im: #{status_code_from_im}, body_string_from_im: #{inspect(body_string_from_im)}")
    case status_code_from_im in expected_status_codes do
      true  -> digest_response_from_im_success(status_code_from_im, body_string_from_im)
      false -> digest_response_from_im_error(  status_code_from_im, body_string_from_im)
    end
  end
  defp digest_response_from_im({:error, %HTTPoison.Error{reason: reason}},
                               _expected_status_codes) do
    Logger.debug("BE:R.digest_response_from_im: reason: #{inspect(reason, pretty: true)}")
    digest_im_connection_error(reason)
  end

  defp digest_response_from_im_success(status_code_from_im, body_string_from_im) do
    Logger.debug("BE:R.digest_response_from_im_success: status_code_from_im: #{status_code_from_im}, body_string_from_im: #{inspect(body_string_from_im)}")
    with {:ok, body_from_im_as_map} <- json2map(body_string_from_im) do
      {:ok, %{success: %{status_code: status_code_from_im,
                         body:        body_from_im_as_map }}}
    else
      {:error, json2map_error} ->
        {:error, json2map_error_map(json2map_error)}
    end
  end

  defp digest_response_from_im_error(status_code_from_im, body_string_from_im) do
    Logger.debug("BE:R.digest_response_from_im_error: status_code_from_im: #{status_code_from_im}, body_string_from_im: #{inspect(body_string_from_im)}")
    with {:ok, body_from_im_as_map} <- json2map(body_string_from_im) do
        {:error, %{errors: %{im_status_code: status_code_from_im,
                             im_body:        body_from_im_as_map}}}
    else
      {:error, json2map_error} ->
        {:error, json2map_error_map(json2map_error)}
    end
  end

  defp digest_im_connection_error(reason) do
    Logger.debug("BE:R.digest_im_connection_error: reason: #{inspect(reason)}")
    {:error, %{errors: %{im_connection_error: reason }}}
  end

  # -------------------- READ DIRECTLY FROM SEARCH ENGINE  ---------------------

  defp handle_request_to_se(method, doc_id, body, expected_status_codes) do
    Logger.debug("BE:R.handle_request_to_se: method: #{method}, doc_id: #{doc_id}, body: #{inspect(body)}, expected_status_codes: #{inspect(expected_status_codes)}")
    send_request_to_se(method, doc_id, body)
    |> digest_response_from_se(expected_status_codes)
  end

  defp send_request_to_se(:get, doc_id, _body), do: SE.Document.get(se_base_url(), @index_name, "_doc", doc_id)

  # --------------------- DIGEST AND TRANSFORM RESPONSE_FROM SE ----------------

  defp digest_response_from_se({:ok, %HTTPoison.Response{status_code: status_code_from_se,
                                                         body:        body_from_se_as_map}},
                               expected_status_codes) do
    Logger.debug("BE:R.digest_response_from_se: status_code_from_se: #{status_code_from_se}, body_from_se_as_map: #{inspect(body_from_se_as_map)}")
    case status_code_from_se in expected_status_codes do
      true  -> digest_response_from_se_success(status_code_from_se, body_from_se_as_map)
      false -> digest_response_from_se_error(  status_code_from_se, body_from_se_as_map)
    end
  end
  defp digest_response_from_se({:error, %HTTPoison.Error{reason: reason}},
                               _expected_status_codes) do
    digest_se_connection_error(reason)
  end

  defp digest_response_from_se_success(status_code_from_se, %{"_id" => _id, "_source" => source}) do
    Logger.debug("BE:R.digest_response_from_se_success: status_code_from_se: #{status_code_from_se}, _source: #{inspect(source)}")
    IO.inspect(source, label: "SOURCE IN DIGEST RESPONSE FROM SE")
    {:ok, %{success: %{status_code: status_code_from_se,
                       body:        source }}}
  end

  defp digest_response_from_se_error(status_code_from_se, body_from_se_as_map) do
    Logger.debug("BE:R.digest_response_from_se_error: status_code_from_se: #{status_code_from_se}, body_from_se_as_map: #{inspect(body_from_se_as_map)}")
    {:error, %{errors: %{se_status_code: status_code_from_se,
                         se_body:        body_from_se_as_map}}}
  end

  defp digest_se_connection_error(reason) do
    Logger.debug("BE:R.digest_se_connection_error: reason: #{inspect(reason)}")
    {:error, %{errors: %{se_connection_error: reason}}}
  end

  # ----------------------------------------------------------------------------

  # For sending JSON data downstream
  def map2json(map) do
    Jason.encode(map)
    |> transform_json_encode_result()
  end
  defp transform_json_encode_result({:ok, json}), do: {:ok, json}
  defp transform_json_encode_result({:error, reason}), do: {:error, inspect(reason)}
  defp map2json_error_map(map2json_error_message) do
    %{errors: %{be_map2json_error: map2json_error_message}}
  end

  # For reading JSON results
  def json2map(json) do
    Jason.decode(json)
    |> transform_json_decode_result()
  end
  defp transform_json_decode_result({:ok, map}), do: {:ok, map}
  defp transform_json_decode_result({:error, reason}), do: {:error, inspect(reason)}
  defp json2map_error_map(json2map_error_message) do
    %{errors: %{be_json2map_error: json2map_error_message}}
  end

  # ----------------------------------------------------------------------------

  def get_all_persons do
    Search.get_all_persons()
  end

  def get_person(id) do
    Search.get_person(id)
  end

  def search_persons(q) do
    Search.search_persons(q)
  end

  def search_persons_gup_person_ids(ids) do
    Search.search_persons_gup_person_ids(ids)
  end


  def serach_merged_persons(q) do
    Search.search_merged_persons(q)
  end

  def try_merge_gup_admin_person(gup_admin_id) do
    IO.inspect("YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO YAHOOO - Merging person with gup_admin_id: #{gup_admin_id} -y")
    Search.get_person(gup_admin_id)
    |> evaluate_person_for_merge()
    |> respond_to_merge_attempt()
  end

  defp respond_to_merge_attempt(:not_found), do: :not_found
  defp respond_to_merge_attempt(:nothing_to_do), do: :nothing_to_do
  defp respond_to_merge_attempt(response) do
    response
  end

  def evaluate_person_for_merge(%{"data" =>nil}), do: :not_found
  def evaluate_person_for_merge(%{"data" => data}) do
    identifiers = data["identifiers"]
    case length(identifiers) do
      0 -> :nothing_to_do
      _ -> try_execute_merge(data)

    end
  end

  def try_execute_merge(person_data) do
   generate_single_name_form_data(person_data)
   |> Enum.map(fn single_name_person_data ->
        # for each single name person data, try to merge in index_manager
        url = im_base_url() <> @im_merge_endpoint <> "?api_key=" <> im_api_key()
        headers = @send_and_receive_json
        method = :post
        body = single_name_person_data
        HTTPoison.post(url, %{"data" => single_name_person_data} |> Jason.encode!(), [{"Content-Type", "application/json"}])
        # TODO: Handle errore
        |> elem(1)
        |> Map.get(:body)
        |> Jason.decode()
        |> elem(1)
        |> Map.get("data")
        |> Map.get("id")

      end)
    |> Enum.uniq()
    |> List.last()
  end

  def generate_single_name_form_data(person_data) do
    person_objects = []
    person_data["names"]
   # for each name in names, create a new person object with that name only
    Enum.map(person_data["names"], fn name ->
    person_data
    |> Map.put("names", [name])
  end)

  end



end
