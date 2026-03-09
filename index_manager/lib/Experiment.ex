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
   @people "people"
   @departments "departments"

   def people do
     @people
   end
   def departments do
     @departments
   end

   def send_to(type) do
     "Sending #{type} to gup"
   end

   def a do
      [%{id: 2, name: "Alice"}, %{id: 33, name: "Bob"}]
      |> Enum.into(%{}, fn %{id: id, name: name} -> {id, name} end)
    end


    def fm do
      existing_identifiers = [
        %{
          "identifiers" => [
            %{"code" => "OC", "value" => "123"},
            %{"code" => "XA", "value" => "ABC"},
            %{"code" => "Hej", "value" => "123"},
          ]
        },
        %{
          "identifiers" => [
            %{"code" => "XA", "value" => "ABC"}
          ]
        },
        %{
          "identifiers" => [

          ]
        },
        %{
          "identifiers" => [
            %{"code" => "OC", "value" => "12s3"},
            %{"code" => "XA", "value" => "ABC"}
          ]
        }
      ]
      |> Enum.flat_map(fn record -> Enum.filter(record["identifiers"], fn identifier -> identifier["code"] ==  "OC" ||  identifier["code"] == "XA" end) end)
      |> Enum.group_by(& &1["code"])
      |> Enum.any?(fn {_code, maps} ->
        values = Enum.map(maps, & &1["value"])
        length(Enum.uniq(values)) > 1
      end)
      |> IO.inspect(label: "Colliding identifiers")



    end

    def compare_name_forms do
      name_form1 = %{"first_name" => "John", "last_name" => "Smith", "gup_person_id" => "123"}
      name_form2 = %{"first_name" => "John", "last_name" => "Smith", "gup_person_id" => "123"}
      name_form3 = %{"first_name" => "John", "last_name" => "Smith", "gup_person_id" => "456"}
      name_form4 = %{"first_name" => "John", "last_name" => "Smith"}
      name_form5 = %{"first_name" => "John B", "last_name" => "Smith", "gup_person_id" => "123"}

      IO.inspect(GupIndexManager.Resource.Persons.Merger.NameForms.is_same_name_form?(name_form1, name_form2), label: "Name form 1 vs 2 (should be true)")
      IO.inspect(GupIndexManager.Resource.Persons.Merger.NameForms.is_same_name_form?(name_form1, name_form3), label: "Name form 1 vs 3 (should be false)")
      IO.inspect(GupIndexManager.Resource.Persons.Merger.NameForms.is_same_name_form?(name_form1, name_form4), label: "Name form 1 vs 4 (should be true)")
      IO.inspect(GupIndexManager.Resource.Persons.Merger.NameForms.is_same_name_form?(name_form3, name_form4), label: "Name form 3 vs 4 (should be true)")
      IO.inspect(GupIndexManager.Resource.Persons.Merger.NameForms.is_same_name_form?(name_form1, name_form5), label: "Name form 1 vs 5 (should be true)")

    end

    def m_m do
      a = %{"names" => [%{"first_name" => "John", "last_name" => "Smith", "primary" => true}]}
      b = %{"names" => [%{"first_name" => "Johnddd", "last_name" => "Smsssith"}]}
      Map.merge(a, b) |> IO.inspect(label: "Merged map")
    end

    def da do
      data = %{

      }

      with {:ok, data} <- db(data),
           {:ok, data} <- dc(data) do
          IO.inspect("All steps succeeded: #{inspect(data)}")
        else
          {:error, reason, data} ->
            IO.inspect("Error in processing: #{reason}, data: #{inspect(data)}")
        end
    end

    def db(data) do
      {:ok, data |> Map.put(:b, "Result from b")}
    end

    def dc(data) do
      {:ok, data |> Map.put(:c, "Result from c")}
    end

    def m_names do
      p1 = %{"names" => [%{"first_name" => "John", "last_name" => "Smith", "primary" => true, "gup_person_id" => 1}]}
      p2 = %{"names" => [%{"first_name" => "John", "last_name" => "Smithy", "primary" => false, "gup_person_id" => 1}]}

      # compare the names in p1 and p2, if they have the same gup_person_id, update the names in p1.
      p1_names = Map.get(p1, "names", [])
      p2_names = Map.get(p2, "names", [])

      updated_names = Enum.map(p2_names, fn name2 ->
        case Enum.find(p1_names, fn name1 -> name1["gup_person_id"] == name2["gup_person_id"] end) do
          nil -> name2
          name1 -> Map.merge(name1, name2)
        end
      end)
      Map.put(p1, "names", updated_names) |> IO.inspect(label: "Updated")


    end

    def corrupt_db do
      # get the 10 flrst recorsds from Person in database.
      GupIndexManager.Model.Person
      |> limit(10)
      |> order_by(asc: :id)
      |> GupIndexManager.Repo.all()
      |> Enum.each(fn person ->
        json = person.json |> Jason.decode!() |> add_bad_name_form() |> Jason.encode!()
        IO.inspect(json, label: "Corrupted json for person with id #{person.id}")
        person |> Ecto.Changeset.change(json: json)
        |> GupIndexManager.Repo.update()
      end)


    end

    defp add_bad_name_form(json) do
      bad_name_form = %{"first_name" => "Corrupted", "last_name" => "Data", "primary" => true, "gup_person_id" => nil}
      names = Map.get(json, "names", [])
      new_names = List.insert_at(names, 0, bad_name_form)
      Map.put(json, "names", new_names)
    end


    def fix_corrupted_data do
      # from table persons in db select records where json contains gup_person_id":null
      from(p in GupIndexManager.Model.Person, where: like(p.json, "%gup_person_id\":null%"))
      |> GupIndexManager.Repo.all()
      |> Enum.each(fn person ->
        json = person.json |> Jason.decode!() |> remove_bad_name_form() |> Jason.encode!()
        person |> Ecto.Changeset.change(json: json) |> GupIndexManager.Repo.update()
      end)
    end

  defp remove_bad_name_form(json) do
    names = Map.get(json, "names", [])
    new_names = Enum.filter(names, fn name -> name["gup_person_id"] != nil end)
    if length(new_names) == 0 do
      raise "No valid name forms left after removing corrupted data"
    end
    Map.put(json, "names", new_names)
  end

  def ooo do
    IO.inspect("GTREDGGGGGG")
  end
end




defmodule FixCoruptedData do
  alias GupIndexManager.Model.Person
  alias GupIndexManager.Repo
  import Ecto.Query

  def fix_corrupted_data do
    # from table persons in db select records where json contains gup_person_id":null
    from(p in Person, where: like(p.json, "%gup_person_id\":null%"))
    |> Repo.all()
    |> Enum.each(fn person ->
      json = person.json |> Jason.decode!() |> remove_bad_name_form() |> Jason.encode!()
      person |> Ecto.Changeset.change(json: json) |> Repo.update()
    end)
  end

  defp remove_bad_name_form(json) do
    names = Map.get(json, "names", [])
    new_names = Enum.filter(names, fn name -> name["gup_person_id"] != nil end)
    if length(new_names) == 0 do
      raise "No valid name forms left after removing corrupted data"
    end
    Map.put(json, "names", new_names)
  end
end
