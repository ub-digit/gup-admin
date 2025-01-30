defmodule GupIndexManagerWeb.PersonController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Persons
  alias GupIndexManagerWeb.ControllerHelpers


  @doc """
  Handles the creation or update of a person based on the provided data.

  ## Parameters
  - conn: The connection struct.
  - params: A map containing the following keys:
    - "data": A map with the key "x_account_status" which should be "inactive".
    - "api_key": The API key for authorization.

  ## Responses
  - Returns a JSON response with status 200 and a message indicating that no actions are necessary if the account is inactive and the API key is valid.
  - Returns a JSON response with status 401 and an error message if the API key is invalid.
  """
  def create_or_update(conn, %{"data" => %{"x_account_status" => account_status} = data, "api_key" => api_key}) do
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        case account_status do
          "active" ->
            Persons.Merger.merge(data) |> GupIndexManager.Resource.Persons.Execute.execute_actions() |> respond(conn)
          _ ->
            json Plug.Conn.put_status(conn, 200), %{status: "200", message: "x_account_status property present but not set to active, no actions necessary"}
        end
      false ->
        json Plug.Conn.put_status(conn, 401), %{status: "401", message: "error, unauthorized key"}
    end
  end

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
    json Plug.Conn.put_status(conn, 200), %{status: "200", message: "error #{error}  see log for details"}

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
