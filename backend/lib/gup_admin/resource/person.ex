defmodule GupAdmin.Resource.Person do
  alias GupAdmin.Resource.Search
  def get_all_persons do
    Search.get_all_persons()
  end

  def get_person(id) do
    Search.get_person(id)
  end
end
