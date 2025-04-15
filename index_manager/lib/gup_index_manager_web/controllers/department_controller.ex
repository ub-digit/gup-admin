defmodule GupIndexManagerWeb.DepartmentController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Gup
  alias GupIndexManagerWeb.ControllerHelpers
  require Logger

  def index(conn, _params) do
    # GupIndexManager.Resource.Departments.initialize()
    json conn, %{"message" => "Indexing departments"}
  end


  def create(conn, %{"api_key" => api_key, "data" => department_data}) do
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        json(conn, GupIndexManager.Resource.Departments.create(department_data))
      false ->
        json Plug.Conn.put_status(conn, 401), %{"status" => "401", "message" => "error, unauthorized key"}
    end
  end

  def update(conn, %{"api_key" => api_key, "id" => id, "data" => department_data}) do
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        json(conn, GupIndexManager.Resource.Departments.update(id, department_data))
      false ->
        json Plug.Conn.put_status(conn, 401), %{"status" => "401", "message" => "error, unauthorized key"}
    end
  end
end
