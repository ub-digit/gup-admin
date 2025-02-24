defmodule GupAdminWeb.PersonController do
  use GupAdminWeb, :controller
  require Logger
  alias GupAdmin.Resource.Person
  plug GupAdminWeb.Plugs.ApiKeyPlug

  ################################
  # Vocabulary
  # FE/fe = frontend
  # BE/be = backend (Gup Admin backend)
  # IM/im = index manager
  # SE/se = search engine (Elasticsearch)

  # GET /persons/id_codes
  def get_id_codes(conn, _) do
    handle_request_from_fe(conn, :get_id_codes, [])
  end

  # POST /persons/:id
  def create( conn, %{"data" => person_map}) do
    handle_request_from_fe(conn, :create, [person_map])
  end

  # PUT /persons/:id
  def update( conn, %{"id" => id, "data" => person_map}) do
    Logger.debug(person_map);
    handle_request_from_fe(conn, :update, [id, person_map])
  end

  # GET /persons/:id
  def show(  conn, %{"id" => id}) do
    handle_request_from_fe(conn, :get, [id])
  end

  # DELETE /persons/:id
  def delete(conn, %{"id" => id}) do
    handle_request_from_fe(conn, :delete, [id])
  end

  #-----------------------------------------------------------------------------------------------

  defp handle_request_from_fe(conn, action, args) do
    apply(GupAdmin.Resource.Person, action, args)
    |> respond_to_fe(conn)
  end

  #-----------------------------------------------------------------------------------------------

  defp respond_to_fe(result_from_resource, conn) do
    Logger.debug("BE:C:respond_to_fe: result_from_resource: #{inspect(result_from_resource)}")
    case result_from_resource do

      # Identifier codes
      {:ok, %{id_codes: %{status_code: status_code, body: body_map}}} ->
        send_response(conn, status_code, body_map)

      # Validation error
      {:error, %{errors: %{fe_validation: validation_error_list},
                           data:          full_person_map}}  ->
      send_response(conn, 200, %{errors: %{validation: validation_error_list},
                                 data:   full_person_map})

      # CRUD success
      {:ok, %{success: %{status_code: status_code, body: body_map}}} ->
        send_response(conn, status_code, %{success: %{status_code: status_code, data: body_map}})

      # CRUD errors
      {:error, %{errors: errors_map = %{im_status_code: im_status_code}}} ->
        send_response(conn, im_status_code, %{errors: errors_map})
      {:error, %{errors: errors_map = %{se_status_code: se_status_code}}} ->
        send_response(conn, se_status_code, %{errors: errors_map})
      {:error, %{errors: %{im_connection_error: reason}}} ->
        send_response(conn, 503, %{errors: %{im_connection_error: reason}})
      {:error, %{errors: %{se_connection_error: reason}}} ->
        send_response(conn, 503, %{errors: %{se_connection_error: reason}})

      {:error, %{errors: errors_map}} ->
        send_response(conn, 500, %{errors: errors_map})

      # What???
      _ ->
        send_response(conn, 500, %{errors: %{be_unknown_error: "UNKNOWN_ERROR"}})
    end
  end

  defp send_response(conn, status_code, body_map) do
    conn
    |> put_status(status_code)
    |> json(body_map)
    |> tap(fn response_conn ->
      Logger.debug(fn ->
        "Response sent to frontend: status=#{response_conn.status}, body=#{inspect(body_map)}"
      end)
    end)

  end

# ------------------------------------------------------------

  def search(conn, %{"isMerged" => "true", "query" => query}) do
    IO.puts("get merged persons")
    json conn, Person.serach_merged_persons(query)
  end

  def search(conn, %{"isMerged" => "true"}) do
    IO.puts("get all merged persons")
    json conn, Person.serach_merged_persons("")
  end


  def search(conn, %{"query" => q}) do
    json conn, Person.search_persons(q)
  end


  def search(conn, _params) do
    json conn, Person.get_all_persons()
  end

  def get_one(conn, %{"id" => id}) do
    json conn, Person.get_person(id)
  end
end
