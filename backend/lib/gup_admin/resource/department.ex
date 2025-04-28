defmodule GupAdmin.Resource.Department do

  require Logger

  ################################
  # Vocabulary
  # BE/be = backend (Gup Admin backend)
  # IM/im = index manager
  # SE/se = search engine (Elasticsearch)

  @im_endpoint           "/api/departments"
  @index_name            "departments"
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


  # -------------------- WRITE THROUGH INDEX MANAGER ---------------------------

  # To IM: POST /department [CREATE]
  def create(department_data) do
    Logger.debug("BE:R.create: department_data: #{inspect(department_data)}")
    case GupAdmin.Resource.Department.DepartmentValidator.validate(department_data) do
      {:ok, department_data} -> map2json(%{data: department_data})
             |> do_create()
     {:error, validation_error_list} -> {:error, %{errors: %{fe_validation: validation_error_list},
                                                   data:   department_data}}
   end
  end

  defp do_create({:ok, body}) do
    handle_request_to_im(:post, "#{@im_endpoint}", [201, 200], headers: @send_and_receive_json,
                                                               body:    body)
  end
  defp do_create({:error, error_message}, _id) do
    {:error, map2json_error_map(error_message)}
  end

  # To IM: PUT /department/:id [UPDATE]
  def update(id, department_data) do
    # Logger.debug("BE:R.update: person_data_as_map: #{inspect(department_data)}")
    case GupAdmin.Resource.Department.DepartmentValidator.validate(department_data) do
       {:ok, department_data} -> map2json(%{data: department_data})
              |> do_update(id)
      {:error, validation_error_list} -> {:error, %{errors: %{fe_validation: validation_error_list},
                                                    data:   department_data}}
    end
  end
  defp do_update({:ok, body}, id) do
    handle_request_to_im(:put, "#{@im_endpoint}/#{id}", [200], headers: @send_and_receive_json,
                                                               body:    body)
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

end
