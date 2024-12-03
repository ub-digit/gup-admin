defmodule GupAdminWeb.PersonController do
  use GupAdminWeb, :controller
  alias GupAdmin.Resource.Person

  def search(conn, %{"isMerged" => "true"}) do
    IO.inspect("KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKk")
    # json conn, Person.get_all_persons() |> Enum.filter(fn person -> length(Map.get(person, "names", [])) > 1 end)
    d = Person.get_all_persons() |> Map.get("data") |> Enum.filter(fn person -> length(Map.get(person, "names", [])) > 1 end)
    r = %{"data" => d, "showing" => length(d), "total" => length(d)}
    IO.inspect(r)
    json conn, %{"data" => d, "showing" => length(d), "total" => length(d)}


  end



  def search(conn, %{"query" => q}) do
    IO.inspect("WHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT")
    json conn, Person.search_persons(q)
  end


  def search(conn, _params) do
    IO.inspect("ssssssssssssssssssssssssssssssssssssssssssssssssss  ")
    json conn, Person.get_all_persons()
  end

  def get_one(conn, %{"id" => id}) do
    json conn, Person.get_person(id)
  end
end
