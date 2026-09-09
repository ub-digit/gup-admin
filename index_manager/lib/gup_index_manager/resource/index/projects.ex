defmodule GupIndexManager.Resource.Index.Projects do
  alias GupIndexManager.Resource.Index
  def index_projects(projects_data) do
    Index.reset_index(Index.get_projects_index())
    bulk_index_data = Index.remap_for_bulk(projects_data, Index.get_projects_index())
    Elastix.Bulk.post(Index.elastic_url(), bulk_index_data)
  end
end
