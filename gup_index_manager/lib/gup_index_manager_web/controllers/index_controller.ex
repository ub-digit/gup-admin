defmodule GupIndexManagerWeb.IndexController do
  use GupIndexManagerWeb, :controller


  def reset_index(conn, %{"index" => index, "api_key" => api_key}) do
    case get_api_key() == api_key do
      true ->  reset_index(conn, index)
      _ -> json conn, %{error: "Invalid API key"}
    end

  end

  def reset_index(conn, index) when is_bitstring(index) do
    case GupIndexManager.Resource.Index.reset_index(index) do
      {:ok, _} -> json conn, %{message: "Index: #{index} reset"}
      {:error, reason} -> json conn, %{error: reason}

    end
  end

  def get_api_key do
    System.get_env("RESET_INDEX_API_KEY")
  end
end
