defmodule GupAdminWeb.PublicationController do
  use GupAdminWeb, :controller
  alias ElixirLS.LanguageServer.Experimental.Protocol.Proto.Macros.Json
  alias GupAdmin.Resource.Search

  # GET /posts
  def index(conn, params) do
    posts = Search.search(params)
    json conn, posts
  end

  # get one post
  def show(conn, %{"id" => id}) do
    post = Search.show(id)
    |> IO.inspect(label: "post")
    |> case do
      :error -> conn |> send_resp(404, Jason.encode!(%{error: %{"message" => "Post not found", "code" => 404}}))
      res -> json conn, res
    end
  end

  def get_duplicates(conn, params) do
    json conn, Search.get_duplicates(params)
  end
end
