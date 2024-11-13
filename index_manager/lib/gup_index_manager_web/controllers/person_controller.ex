defmodule GupIndexManagerWeb.PersonController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Persons
  alias GupIndexManagerWeb.ControllerHelpers

  def create_or_update(conn,  %{"data" => data, "api_key" => api_key}) do

    case ControllerHelpers.check_api_key(api_key) do
      true ->
        Persons.Merger.merge(data) |> GupIndexManager.Resource.Persons.Execute.execute_actions() |> respond(conn)
      false ->
        json Plug.Conn.put_status(conn, 401), %{status: "401", message: "error, unauthorized key"}
    end
  end

  def respond({:error, error, error_log_data}, conn) do
    GupIndexManager.Resource.Logger.log({:error, error, error_log_data})
    json Plug.Conn.put_status(conn, 500), %{status: "500", message: "Internal server error"}

  end

  def respond({:ok, _data, :no_actions}, conn) do
    json Plug.Conn.put_status(conn, 200), %{status: "200", message: "No actions necessary"}
  end

  def respond({:ok, _res_data}, conn) do
    json Plug.Conn.put_status(conn, 201), %{status: "201", message: "Person updated"}
  end

  def index(conn, _params) do
    json conn, Persons.get_all()
  end

end
