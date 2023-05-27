#controllrer for the publication page
defmodule GupIndexManagerWeb.PublicationController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Publication
  def create_or_update(conn,  %{"data" => data, "api_key" => "megasecretimpossibletoguesskey"}) do
    Publication.create_or_update(data)
    json conn, %{status: "ok"}
  end

  def create_or_update(conn, _params) do
    json conn, %{status: "error"}
  end

  def list(conn, _params) do
    json conn, Publication.list()
  end
end
