defmodule GupAdminWeb.PublicationTypeController do
  use GupAdminWeb, :controller
  alias GupAdmin.Resource.PublicationType

  def index(conn, _params) do
    publication_types = PublicationType.get_publication_types()
    json(conn, %{publication_types: publication_types})
  end
end
