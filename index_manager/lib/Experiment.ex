defmodule Experiment do
  @moduledoc """
  Module to generate dummy posts with randomized content using string keys.
  """

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

  def create() do
    %{
      "names" => [
        %{
          "first_name" => "John",
          "last_name" => "Doe",
          "full_name" => "John Doe",
          "start_date" => "2023-03-09",
          "end_date" => nil,
          "gup_person_id" => "11111",
          "primary" => true
        },
        %{
          "first_name" => "Jane",
          "last_name" => "Doe",
          "full_name" => "Jane Doe",
          "start_date" => "2023-03-09",
          "end_date" => nil,
          "primary" => false
        },
        %{
          "first_name" => "John",
          "last_name" => "Smith",
          "full_name" => "John Smith",
          "start_date" => "2023-03-09",
          "end_date" => nil,
          "primary" => false
        }

      ],
      "identifiers" => [
        %{
          "code" => "X_ACCOUNT",
          "value" => "xbemib"
        }
      ],
    }
    |> IO.inspect(label: "Generated post")
    |> GupIndexManager.Resource.Persons.create()
  end
end
