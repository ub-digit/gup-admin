defmodule GupIndexManager.Resource.Index.Search do
  alias GupIndexManager.Resource.Index.Query
  alias GupIndexManager.Resource.Index

  def find_person_by_identifiers([]), do: {false, []}

  def find_person_by_identifiers(identifiers) do
    q = Query.find_person_by_identifiers(identifiers)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    {length(hits) > 0, hits}
  end

  def find_person_by_gup_id(gup_id) do
    q = Query.find_person_by_gup_id(gup_id)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    {length(hits) > 0, hits}
  end

  def find_person_by_gup_admin_id(gup_admin_id) do
    q = Query.find_person_by_gup_admin_id(gup_admin_id)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    {length(hits) > 0, hits}
  end

  def get_all_persons do
    q = Query.get_all_persons()
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    hits
    |> remap_persons()
  end

  def remap_persons(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
    # |> Enum.filter(fn person -> Map.get(person, "deleted", false) == false end)
  end

  def get_all_departments do
    q = Query.get_all_departments()
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_departments_index(), [], q)
    hits
    |> remap_departments()
  end
  def remap_departments(hits) do
    hits
    |> Enum.map(fn hit ->
      hit
      |> Map.get("_source")
    end)
  end
end
