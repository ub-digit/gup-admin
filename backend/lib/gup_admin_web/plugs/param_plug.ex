defmodule GupAdminWeb.ParamPlug do
  alias Plug.Conn

  def init(opts) when is_map(opts), do: opts
  def init(_), do: %{}

  def call(%Plug.Conn{params: params} = conn, opts) do
    #IO.inspect(Plug.Conn.fetch_query_params(conn), label: "qp")
    %{conn | params: typeset_params(params, opts)}
  end

  def typeset_params(params, opts) do
    #IO.inspect(opts, label: "typeset_params.opts")
    #IO.inspect(params, label: "typeset_params.params")
    params
    |> Enum.reduce(%{}, fn {param,value}, typed_params -> Map.put(typed_params, param, typeset_value(value, opts[param])) end)
    |> Map.new
    |> IO.inspect(label: "typeset_params.map")
  end

  def typeset_value(value, _) when is_nil(value), do: nil

  def typeset_value(value, :integer) do
    case Integer.parse(value) do
      {intvalue, _} -> intvalue
      :error -> :error
    end
  end

  def typeset_value(value, :boolean) do
    case value do
      "true" -> true
      "false" -> false
      "yes" -> true
      "no" -> false
      _ -> :error
    end
  end

  def typeset_value(value, :boolean_array) do
    value
    |> Enum.map(fn v -> typeset_value(v, :boolean) end)
  end

  def typeset_value(value, :integer_array) do
    value
    |> Enum.map(fn v -> typeset_value(v, :integer) end)
  end

  def typeset_value(value, _), do: value
end
