defmodule GupIndexManager.Resource.Index.Search do
  alias GupIndexManager.Resource.Index.Query
  alias GupIndexManager.Resource.Index

  def find_person_by_identifiers([]), do: {false, []}

  def find_person_by_identifiers(identifiers) do
    q = Query.find_person_by_identifiers(identifiers)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    hits
    |> length()
    |> case do
      0 -> {false, nil}
      _ -> {true, hits |> List.first() |> Map.get("_source")}
    end

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
  end

  def find_person_by_x_account(x_account) do
    q = Query.find_person_by_x_account(x_account)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    hits
    |> length()
    |> case do
      0 -> {false, nil}
      _ -> {true, hits |> List.first() |> Map.get("_source")}
    end
  end


  def find_person_by_gup_person_id(nil), do: {false, nil}

  def find_person_by_gup_person_id(gup_person_id) do
    q = Query.find_person_by_gup_person_id(gup_person_id)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    hits
    |> length()
    |> case do
      0 -> {false, nil}
      _ -> {true, hits |> List.first() |> Map.get("_source")}
    end
  end
end
