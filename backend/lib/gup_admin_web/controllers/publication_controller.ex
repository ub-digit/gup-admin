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
    json conn, post
  end
end
