defmodule GupIndexManagerWeb.PersonController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Persons
  alias GupIndexManagerWeb.ControllerHelpers

  def create_or_update(conn,  %{"data" => data, "api_key" => api_key}) do

    case ControllerHelpers.check_api_key(api_key) do
      true ->
        json conn, Persons.Merger.merge(data)#Persons.create_or_update(data)
      false ->
        json conn, %{status: "error, unauthorized key"}
    end
  end

  def index(conn, _params) do
    json conn, Persons.get_all()
  end

end
