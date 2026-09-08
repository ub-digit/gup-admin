defmodule GupIndexManager.Resource.Index.Series do
  alias GupIndexManager.Resource.Index
  def index_series(series_data) do
    Index.reset_index(Index.get_series_index())
    bulk_index_data = Index.remap_for_bulk(series_data, Index.get_series_index())
    res = Elastix.Bulk.post(Index.elastic_url(), bulk_index_data)

    IO.inspect(series_data, label: "Indexing series with data")
    IO.inspect(res, label: "Indexing series with response")
    :ok
  end
end
