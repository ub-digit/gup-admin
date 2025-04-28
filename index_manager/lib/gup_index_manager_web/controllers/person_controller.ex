defmodule GupIndexManagerWeb.PersonController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Persons
  alias GupIndexManagerWeb.ControllerHelpers

  require Logger

  def create_or_update(conn,  %{"data" => data, "api_key" => api_key} = params) do
    force_primary_name = Map.get(params, "force_primary_name", false)
    initial_load = Map.get(params, "initial_load", false)
    Logger.debug "IM:C.create_or_update: force_primary_name: #{inspect(force_primary_name)}"
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        Persons.Merger.merge(Map.put(data, "force_primary_name", force_primary_name == "true")) |> Persons.Execute.execute_actions() |> GupIndexManager.Resource.Gup.update_gup(initial_load == "true") |> respond(conn)
      false ->
        json Plug.Conn.put_status(conn, 401), %{status: "401", message: "error, unauthorized key"}
    end
  end

  def respond({:error, error, error_log_data}, conn) do
    GupIndexManager.Resource.Logger.log({:error, error, error_log_data})
    json Plug.Conn.put_status(conn, 200), %{status: "200", message: "error #{error}  see log for details"}

  end

  def respond({:ok, _data, :no_actions}, conn) do
    json Plug.Conn.put_status(conn, 200), %{status: "200", message: "No actions necessary", data: _data}
  end

  def respond({:ok, _res_data}, conn) do
    json Plug.Conn.put_status(conn, 201), %{status: "201", message: "Person updated", data: _res_data}
  end

  def index(conn, _params) do
    json conn, Persons.get_all()
  end

  ################################
  # Vocabulary
  # BE/be = backend (Gup Admin backend)
  # IM/im = index manager

#-----------------------------------------------------------------------------------------------

  # Create [POST /persons/:id]
  def create(conn, %{"api_key" => api_key, "data" => person_data_as_map}) do
    Logger.debug "IM:C.create: data: #{inspect(person_data_as_map)}"
    handle_request_from_be(conn, api_key, :create, [person_data_as_map])
  end

  # Update [PUT /persons/:id]
  def update(conn, %{"api_key" => api_key, "id" => id, "data" => person_data_as_map}) do
    Logger.debug "IM:C.update: id: #{inspect(id)}, data: #{inspect(person_data_as_map)}"
    handle_request_from_be(conn, api_key, :update, ["#{id}", person_data_as_map])
  end

  # Delete [DELETE /persons/:id]
  def delete(conn, %{"api_key" => api_key, "id" => id}) do
    Logger.debug "IM:C.delete: id: #{inspect(id)}"
    handle_request_from_be(conn, api_key, :delete, ["#{id}"])
  end

#-----------------------------------------------------------------------------------------------

  defp handle_request_from_be(conn, api_key, action, args) do
    with true <- GupIndexManagerWeb.ControllerHelpers.check_api_key(api_key) do
      apply(GupIndexManager.Resource.Persons, action, args)
      |> respond_to_be(conn)
    else
      false ->
        send_response(conn, 401, %{errors: %{im_message: "Unauthorized"}})
    end
  end

#-----------------------------------------------------------------------------------------------

  defp respond_to_be(result_from_resource, conn) do
    case result_from_resource do
      %{"status" => "ok"} ->
        body_map = %{status: "ok"}
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
