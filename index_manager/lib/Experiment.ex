defmodule Experiment do
  @moduledoc """
  Module to generate dummy posts with randomized content using string keys.
  """
  import Ecto.Query
  alias GupIndexManager.Model
  alias GupIndexManager.Repo

  require Logger

  # Template for a dummy post
  @base_post %{
    "abstract" => "Default abstract content.",
    "article_number" => nil,
    "attended" => false,
    "authors" => [],
    "created_at" => "2023-03-09T03:05:16",
    "deleted" => false,
    "eissn" => nil,
    "id" => nil,
    "isbn" => "9783030180010",
    "issn" => nil,
    "keywords" => nil,
    "origin_id" => nil,
    "publication_identifiers" => [],
    "publication_type_id" => 10,
    "publication_type_label" => "Kapitel i bok",
    "pubyear" => nil,
    "ref_value" => "NOTREF",
    "source" => "scopus",
    "sourceissue" => nil,
    "sourcepages" => "193-215",
    "sourcetitle" => "The European Union in a Changing World Order: Interdisciplinary European Studies",
    "sourcevolume" => nil,
    "title" => "Default Title",
    "updated_at" => "2023-03-09T03:05:16"
  }

  # Function to generate randomized author data
  defp random_authors do
    first_names = ["John", "Ann", "Maria", "Douglas", "Alex", "Sarah", "Michael"]
    last_names = ["Smith", "Johnson", "Brown", "Ekengren", "Brommesson", "Garcia"]

    Enum.map(1..:rand.uniform(3), fn position ->
      %{
        "affiliations" => [
          %{
            "scopus_affiliation_city" => Enum.random(["Lund", "Gothenburg", "Stockholm", "Uppsala"]),
            "scopus_affiliation_country" => "Sweden",
            "scopus_affilname" => Enum.random(["Lunds Universitet", "Göteborgs Universitet", "Uppsala Universitet"]),
            "scopus_afid" => "#{:rand.uniform(999999)}"
          }
        ],
        "person" => [
          %{
            "first_name" => Enum.random(first_names),
            "identifiers" => [%{"type" => "scopus-auth-id", "value" => "#{:rand.uniform(999999999)}"}],
            "last_name" => Enum.random(last_names),
            "position" => "#{position}"
          }
        ]
      }
    end)
  end

  # Function to generate a single dummy post
  def generate_dummy_post do
    Map.merge(@base_post, %{
      "abstract" => "This is a dummy abstract with unique content #{:rand.uniform(1000)}.",
      "title" => "Generated Title #{:rand.uniform(1000)}",
      "pubyear" => "#{Enum.random(2000..2024)}",
      "id" => "scopus_#{:rand.uniform(1_000_000)}",
      "origin_id" => "#{:rand.uniform(1_000_000)}",
      "publication_identifiers" => [
        %{"identifier_code" => "scopus-id", "identifier_value" => "#{:rand.uniform(1_000_000_000)}"},
        %{"identifier_code" => "doi", "identifier_value" => "10.1007/978-3-030-#{:rand.uniform(99999)}_#{:rand.uniform(9)}"}
      ],
      "authors" => random_authors()
    })
  end

  # Function to generate N dummy posts
  def generate_dummy_posts(count \\ 100) when is_integer(count) and count > 0 do
    Enum.map(1..count, fn _ -> generate_dummy_post() end)
    |> Enum.map(fn post -> GupIndexManager.Resource.Publication.create_or_update(post) end)
  end


  def find do
    z = [%{"v" => 1, "name" => "leif"}, %{"v" => 2, "name" => "leif"}, %{"v" => 3, "name" => "leif"}, %{"v" => 4, "name" => "leif"}, %{"v" => 5, "name" => "leif"}]
    # in case there is a map in z that has a key "v" with value 3, return that maps value for key "name"
    Enum.find_value(z, fn %{"v" => v, "name" => name} -> if v == 3, do: name end)
  end

  def rebuild_index_bulk(limit\\ 1, offset \\ 0) do
    IO.inspect("Rebuilding index posts #{offset} to #{offset + limit}")
    from(p in GupIndexManager.Model.Publication, select: p, limit: ^limit, offset: ^offset)
    |> GupIndexManager.Repo.all()
    |> build_bulk_rows(limit, offset)
    |> bulk_index(limit, offset)

  end
  def bulk_index({:ok, "Done"}, _, _), do: {:ok, "Done"}
  def bulk_index(index_data, limit, offset) do
    Elastix.Bulk.post("http://elasticsearch:9200", index_data)
    offset = offset + limit
    rebuild_index_bulk(limit, offset)
  end

  def build_bulk_rows([], _limit, _offset), do: {:ok, "Done"}
  def build_bulk_rows(data, _limit, _offset) do
    data
    |> remap_for_index()
    |> remap_for_bulk("publications")
  end

  def remap_for_index(publications) do
    publications
    |> Enum.map(fn publication ->
      publication.json |> Jason.decode!()
      |> Map.put("attended", publication.attended)
      |> Map.put("deleted", publication.deleted)
    end)
  end

  def remap_for_bulk(data, index) do
    Enum.map(data, fn publication ->
      [%{"index" =>  %{"_index" => index, "_id" => publication["id"]}},
      publication]
    end)
    |> List.flatten()
  end


  def get_from_db do
    GupIndexManager.Model.Department
    |> GupIndexManager.Repo.all()

  end
end
