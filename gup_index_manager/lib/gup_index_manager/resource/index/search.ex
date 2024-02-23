defmodule GupIndexManager.Resource.Index.Search do
  alias GupIndexManager.Resource.Index.Query
  alias GupIndexManager.Resource.Index

  def find_person_by_identifiers(identifiers) do
    q = Query.find_person_by_identifiers(identifiers)
    IO.inspect(q, label: "q")
    {:ok, %{body: %{"hits" => %{"hits" => hits}}}} = Elastix.Search.search(Index.elastic_url(), Index.get_persons_index(), [], q)
    IO.inspect(hits, label: "hits -s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s-s")
    {length(hits) > 0, hits}
  end
end
