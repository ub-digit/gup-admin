defmodule GupIndexManagerWeb.SeriesController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Index.Series

  def index_series(conn, %{"api_key" => api_key, "data" => series_data}) do
     with true <- GupIndexManagerWeb.ControllerHelpers.check_api_key(api_key) do
      with :ok <- Series.index_series(series_data) do
        send_response(200, conn, %{message: "Series re-indexed successfully"})
      else
        {:error, reason} ->
          send_response(500, conn, %{errors: %{im_message: "Failed to index series", reason: reason}})
      end
    else
      false ->
        send_response(401, conn, %{errors: %{im_message: "Unauthorized"}})
    end
  end

  defp send_response(status, conn, body) do
    conn |> put_status(status)

    |> json(body)
  end
end
