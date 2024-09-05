defmodule GupAdminWeb.PublicationController do
  use GupAdminWeb, :controller
  alias GupAdmin.Resource.Search
  alias GupAdmin.Resource.Publication

  # GET /posts
  def index(conn, params) do
    posts = Search.search(params)
    json conn, posts
  end

  # get one post
  def show(conn, %{"id" => id}) do
    Publication.show(id)
    |> IO.inspect(label: "post")
    |> case do
      :error -> conn |> send_resp(404, Jason.encode!(%{error: %{"message" => "Post not found", "code" => 404}}))
      res -> json conn, res
    end
  end

  def show_authors(conn, %{"id" => id}) do
    Publication.show_authors(id)
    |> IO.inspect(label: "authors")
    |> case do
      :error -> conn |> send_resp(404, Jason.encode!(%{error: %{"message" => "Post not found", "code" => 404}}))
      res -> json conn, res
    end
  end

  def get_duplicates(conn, params) do
    json conn, Search.get_duplicates(params)
  end

  def delete(conn, %{"id" => id}) do
    Search.mark_as_deleted(id)
    |> case do
      :error -> conn |> send_resp(404, Jason.encode!(%{error: %{"message" => "Post not found", "code" => 404}}))
      _ -> json conn, %{"Status" => "post deleted"}
    end
  end

  def post_to_gup(conn, %{"id" => id, "gup_user" => gup_user}) do
    Publication.post_publication_to_gup(id, gup_user)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->  conn |> send_resp(200, Jason.encode!(%{"message" => "Post successfully posted to GUP", "link" => get_gup_link(body)}))
      {:ok, %HTTPoison.Response{status_code: 400}} -> conn |> send_resp(400, Jason.encode!(%{error: %{"message" => "Post already exists in GUP", "code" => 400}}))
      {:ok, %HTTPoison.Response{status_code: 500}} -> conn |> send_resp(500, Jason.encode!(%{error: %{"message" => "Internal server error", "code" => 500}}))
      {:error, %HTTPoison.Error{reason: reason}} -> conn |> send_resp(500, Jason.encode!(%{error: %{"message" => reason, "code" => 500}}))
    end
  end

  def get_gup_link(body) do
    "#{System.get_env("GUP_BASE_URL", "https://gup-lab.ub.gu.se")}/publications/show/#{get_id(body)}"
  end

  def get_id(body) do
    body
    |> Jason.decode!()
    |> Map.get("publication")
    |> Map.get("id")
  end

  def compare(conn, %{"imported_id" => imported_id, "gup_id" => gup_id}) do
    GupAdmin.Resource.Publication.compare_posts(imported_id, gup_id)
    |> case do
      {:ok, data} -> conn |> send_resp(200, Jason.encode!(data))
      {:error, %{"statusCode" => statusCode}} ->
        case statusCode do
          "404" -> conn |> send_resp(404, Jason.encode!(%{error: %{"code" => "404", "message" => "Left side post not found"}}))
          _ -> conn |> send_resp(202, Jason.encode!(%{error: %{"code" => "200", "message" => "Right side post not found"}}))
        end

    end
  end

  def merge_publications(conn, %{"publication_id" => publication_id, "gup_id" => gup_id, "gup_user" => gup_user}) do
    Publication.merge_publications(gup_id, publication_id, gup_user)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->  conn |> send_resp(200, Jason.encode!(%{"message" => "Post successfully posted to GUP", "link" => get_gup_link(body)}))
      {:ok, %HTTPoison.Response{status_code: 400}} -> conn |> send_resp(400, Jason.encode!(%{error: %{"message" => "Post already exists in GUP", "code" => 400}}))
      {:ok, %HTTPoison.Response{status_code: 500}} -> conn |> send_resp(500, Jason.encode!(%{error: %{"message" => "Internal server error", "code" => 500}}))
      {:error, %HTTPoison.Error{reason: reason}} -> conn |> send_resp(500, Jason.encode!(%{error: %{"message" => reason, "code" => 500}}))
      _ -> conn |> send_resp(200, Jason.encode!(%{message: %{"message" => "Publications merged!", "code" => "200"}}))
    end
  end
end
