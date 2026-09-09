defmodule GupIndexManagerWeb.ProjectController do
  use GupIndexManagerWeb, :controller
  alias GupIndexManager.Resource.Index.Projects

  def index_projects(conn, %{"api_key" => api_key, "data" => projects_data}) do
     with true <- GupIndexManagerWeb.ControllerHelpers.check_api_key(api_key) do
      with {:ok, _} <- Projects.index_projects(projects_data) do
        send_response(200, conn, %{message: "Projects indexed successfully"})
      else
        {:error, reason} ->
          send_response(500, conn, %{errors: %{im_message: "Failed to index projects", reason: reason}})
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
