#controllrer for the publication page
defmodule GupIndexManagerWeb.PublicationController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Publication
  alias GupIndexManagerWeb.ControllerHelpers
  def create_or_update(conn,  %{"data" => data, "api_key" => api_key}) do

    case ControllerHelpers.check_api_key(api_key) do
      true ->
        json conn, Publication.create_or_update(data)
      false ->
        json conn, %{status: "error, unauthorized key"}
    end
  end

  def delete(conn,  %{"id" => id, "api_key" => api_key}) do
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        Publication.delete(id)
        json conn, %{status: "ok"}
      false ->
        json conn, %{status: "error, unauthorized key"}
    end
  end

  def list(conn, _params) do
    json conn, Publication.list()
  end

  def mark_as_pending(conn, %{"id" => id, "api_key" => api_key}) do
    case ControllerHelpers.check_api_key(api_key) do
      true ->
        Publication.mark_as_pending(id)
        json conn, %{status: "ok"}
      false ->
        json conn, %{status: "error, unauthorized key"}
    end
  end
end
