defmodule GupIndexManager.Maintenance do

  alias GupIndexManager.Resource.Index

  def setup_indexes do
    Index.get_indexes()
    |> Enum.map(fn index -> Index.create_index(index) end)
  end

  def setup_index(index_name) do
    Enum.any?(Index.get_indexes(), &(&1 == index_name))
    |> case do
      true -> Index.create_index(index_name)
      false -> IO.puts("Index #{index_name} is not a valid index name.")
    end
  end
end
