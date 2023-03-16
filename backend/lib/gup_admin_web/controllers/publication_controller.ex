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

  def get_duplicates(conn, params) do
    json conn, Search.get_duplicates(params)
  end
end
