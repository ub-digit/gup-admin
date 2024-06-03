defmodule GupIndexManagerWeb.DepartmentController do
  use GupIndexManagerWeb, :controller

  def index(conn, _params) do
    GupIndexManager.Resource.Departments.initialize()
    json conn, %{"message" => "Indexing departments"}
  end

end
