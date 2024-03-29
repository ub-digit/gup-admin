# build elasticsearch filter
defmodule GupAdmin.Resource.Search.Filter do
  def build_filter(filter) do
    filter
    |> Enum.map(fn {key, val} -> format_filter_item({key, val}) end)
  end

  def build_duplicate_filter(publication) do
    %{
      "scopus_id" => publication["scopus_id"] || nil,
      "wos_id" => publication["wos_id"] || nil,
      "doi" => publication["doi"] || nil,
    }
    |> Enum.filter(fn {_, val} -> not is_nil(val) end)
    |> format_filter_item()
  end

  def add_filter(query, nil), do: query
  def add_filter(query, []), do: query

  def add_filter(query, filter) do
    query
    |> put_in(["query", "bool", "filter"], filter)
   # |> IO.inspect(label: "query")
  end

  def format_filter_item(filter) when is_list(filter) do
    %{
      "bool" => %{
        "should" => List.flatten(Enum.map(filter, fn {key, val} -> %{"match" => %{key => val}} end))
      }
    }
  end

  def format_filter_item({key, v}) when is_list(v) do
    %{
      "bool" => %{
        "should" => List.flatten(Enum.map(v, fn val -> %{"match" => %{key => val}} end))
      }
    }
  end

  def format_filter_item({k, v}) do
    %{"match" => %{k => v}}
  end
end
