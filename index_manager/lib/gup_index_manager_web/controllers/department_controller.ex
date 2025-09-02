defmodule GupIndexManagerWeb.DepartmentController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Gup
  alias GupIndexManager.Resource.Departments
  alias GupIndexManagerWeb.ControllerHelpers
  require Logger

  def index(conn, _params) do
    # GupIndexManager.Resource.Departments.initialize()
    json conn, %{"message" => "Indexing departments"}
  end


  # def create(conn, %{"api_key" => api_key, "data" => department_data}) do
  #   case ControllerHelpers.check_api_key(api_key) do
  #     true ->
  #       json(conn, GupIndexManager.Resource.Departments.create(department_data))
  #     false ->
  #       json Plug.Conn.put_status(conn, 401), %{"status" => "401", "message" => "error, unauthorized key"}
  #   end
  # end

  # def update(conn, %{"api_key" => api_key, "id" => id, "data" => department_data}) do
  #   case ControllerHelpers.check_api_key(api_key) do
  #     true ->
  #       json(conn, GupIndexManager.Resource.Departments.update(id, department_data))
  #     false ->
  #       json Plug.Conn.put_status(conn, 401), %{"status" => "401", "message" => "error, unauthorized key"}
  #   end
  # end

   ################################
  # Vocabulary
  # BE/be = backend (Gup Admin backend)
  # IM/im = index manager


#-----------------------------------------------------------------------------------------------
def create(conn, %{"api_key" => api_key, "data" => department_data, "parent_id" => parent_id, "is_faculty" => is_faculty, "initial_load" => initial_load}) do
  # Logger.debug "IM:C.create: data: #{inspect(department_data)}"
  handle_request_from_be(conn, api_key, :create, [department_data, parent_id, is_faculty])
end


def create(conn, %{"api_key" => api_key, "data" => department_data, "parent_id" => parent_id, "is_faculty" => is_faculty}) do
  # Logger.debug "IM:C.create: data: #{inspect(department_data)}"
  handle_request_from_be(conn, api_key, :create, [department_data, parent_id, is_faculty])
end

  # Create [POST /departments/:id]
  def create(conn, %{"api_key" => api_key, "data" => %{"initial_load" => "true"} = department_data,}) do

    Logger.debug "M:C.create: data: #{inspect(department_data)}"
    handle_request_from_be(conn, api_key, :create, [department_data, true])
  end

  def create(conn, %{"api_key" => api_key, "data" => department_data}) do
    Logger.debug "M:C.create: data: #{inspect(department_data)}"
    handle_request_from_be(conn, api_key, :create, [department_data])
  end



  # Update [PUT /departments/:id]
  def update(conn, %{"api_key" => api_key, "id" => id, "data" => department_data}) do
    Logger.debug "IM:C.update: id: #{inspect(id)}, data: #{inspect(department_data)}"
    handle_request_from_be(conn, api_key, :update, ["#{id}", department_data])
  end

  # Delete [DELETE /departments/:id]
  def delete(conn, %{"api_key" => api_key, "id" => id}) do
    Logger.debug "IM:C.delete: id: #{inspect(id)}"
    handle_request_from_be(conn, api_key, :delete, ["#{id}"])
  end

#-----------------------------------------------------------------------------------------------

  defp handle_request_from_be(conn, api_key, action, args) do
    with true <- GupIndexManagerWeb.ControllerHelpers.check_api_key(api_key) do
      apply(GupIndexManager.Resource.Departments, action, args)
      |> respond_to_be(conn)
    else
      false ->
        send_response(conn, 401, %{errors: %{im_message: "Unauthorized"}})
    end
  end

#-----------------------------------------------------------------------------------------------

  defp respond_to_be(result_from_resource, conn) do
    id = Map.get(result_from_resource, "id", nil)
    case result_from_resource do
      %{"status" => "ok"} ->
        body_map = %{status: "ok", id: id}
        send_response(conn, 200, body_map)

      {:error, %{errors: %{im_message: "ID_MISMATCH_BETWEEN_URL_AND_DATA"}} = errors_map} ->
        send_response(conn, 409, errors_map)

      {:error, %{errors: %{}} = errors_map} ->
        Logger.debug "IM:C.respond_to_be: errors_map: #{inspect(errors_map, pretty: true)}"
        send_response(conn, 500, errors_map)

      _ ->
        send_response(conn, 500, %{errors: %{im_unknown_error: "UNKNOWN_ERROR"}})
    end
  end

  defp send_response(conn, status_code, body_map) do
    conn
    |> put_status(status_code)
    |> json(body_map)
  end

end
