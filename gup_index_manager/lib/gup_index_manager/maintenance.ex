defmodule GupIndexManager.Maintenance do

  alias GupIndexManager.Resource.Index

  def setup_indexes do
    Index.get_indexes()
    |> Enum.map(fn index -> Index.create_index(index) end)
  end

  def setup_index(index_name) do
    Index.create_index(index_name)
  end

end
