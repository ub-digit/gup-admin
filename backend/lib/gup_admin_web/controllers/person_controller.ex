defmodule GupAdminWeb.PersonController do
  use GupAdminWeb, :controller

  def index(conn, _params) do
    json conn, GupAdmin.Resource.Search.get_all_persons()
  end
end
