defmodule GupAdminWeb.PersonController do
  use GupAdminWeb, :controller
  alias GupAdmin.Resource.Person
  def index(conn, _params) do
    json conn, Person.get_all_persons()
  end

  def get_one(conn, %{"id" => id}) do
    json conn, Person.get_person(id)
  end
end
