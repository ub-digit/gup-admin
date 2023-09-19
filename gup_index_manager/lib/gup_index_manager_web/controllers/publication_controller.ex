#controllrer for the publication page
defmodule GupIndexManagerWeb.PublicationController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Publication
  def create_or_update(conn,  %{"data" => data, "api_key" => "megasecretimpossibletoguesskey"}) do
    IO.inspect(data, label: "GupIndexManagerWeb.PublicationController.create_or_update")
    Publication.create_or_update(data)
    json conn, %{status: "ok"}
  end

  def create_or_update(conn, _params) do
    json conn, %{status: "error"}
  end

  def delete(conn,  %{"id" => id, "api_key" => "megasecretimpossibletoguesskey"}) do
    IO.inspect(id, label: "GupIndexManagerWeb.PublicationController.delete")
    Publication.delete(id)
    json conn, %{status: "ok"}
  end

  def delete(conn, _params) do
    json conn, %{status: "error"}
  end

  def list(conn, _params) do
    json conn, Publication.list()
  end

  def mark_as_pending(conn, %{"id" => id, "api_key" => "megasecretimpossibletoguesskey"}) do
    Publication.mark_as_pending(id)
    json conn, %{status: "ok"}
  end
end
