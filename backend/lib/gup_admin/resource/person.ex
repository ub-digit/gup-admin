defmodule GupAdmin.Resource.Person do
  alias GupAdmin.Resource.Search
  def get_all_persons do
    Search.get_all_persons()
  end

  def get_person(id) do
    Search.get_person(id)
  end

  def search_persons(q) do
    Search.search_persons(q)
  end

  def serach_merged_persons(q) do
    Search.search_merged_persons(q)
  end
end
