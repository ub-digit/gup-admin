defmodule GupAdminWeb.DepartmentController do
  use GupAdminWeb, :controller

  def get_departments(conn, params) do
    json conn, GupAdmin.Resource.Search.search_departments(params)
  end
end
