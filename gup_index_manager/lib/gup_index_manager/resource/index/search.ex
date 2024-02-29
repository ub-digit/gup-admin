defmodule GupIndexManager.Resource.Index.Search do
  alias GupIndexManager.Resource.Index.Query
  alias GupIndexManager.Resource.Index

  def find_person_by_identifiers(identifiers) do
    q = Query.find_person_by_identifiers(identifiers)
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    {length(hits) > 0, hits}
  end
end
