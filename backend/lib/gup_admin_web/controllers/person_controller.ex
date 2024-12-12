defmodule GupAdminWeb.PersonController do
  use GupAdminWeb, :controller
  alias GupAdmin.Resource.Person



  def search(conn, %{"isMerged" => "true", "query" => query}) do
    IO.puts("get merged persons")
    json conn, Person.serach_merged_persons(query)
  end

  def search(conn, %{"isMerged" => "true"}) do
    IO.puts("get all merged persons")
    json conn, Person.serach_merged_persons("")
  end


  def search(conn, %{"query" => q}) do
    json conn, Person.search_persons(q)
  end


  def search(conn, _params) do
    json conn, Person.get_all_persons()
  end

  def get_one(conn, %{"id" => id}) do
    json conn, Person.get_person(id)
  end
end
