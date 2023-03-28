defmodule GupAdminWeb.PublicationController do
  use GupAdminWeb, :controller
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
      :error -> Plug.Conn.put_status(conn, 404); json conn, %{"statusCode" => 404, "statusMessage" => "Post not found"}
      res -> json conn, res
    end
  end

  def get_duplicates(conn, params) do
    json conn, Search.get_duplicates(params)
  end
end
