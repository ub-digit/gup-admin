defmodule Experiment do
  def test do
    json = %{"id" => 1, "name" => "John"} |> Jason.encode!()
    creator = "xblars"
    attended = false
    publication_id = "gup_234234234"

    %{
      "json" => json,
      "creator" => creator,
      "attended" => attended,
      "publication_id" => publication_id
    }
    |> GupIndexManager.Resource.Publication.create_or_update()
  end

  def auto_put do


    api_key = System.get_env("GUP_INDEX_MANAGER_API_KEY", "megasecretimpossibletoguesskey")
    url = "http://localhost:4010/publications?api_key=#{api_key}"

    load_gup_data(20)
    |> Enum.map(fn item ->
      body = %{"data" => item} |> Jason.encode!()
      HTTPoison.put(url, body, [{"Content-Type", "application/json"}])
    end)



  end

  def get_gup_file_names() do
    File.ls!("../data/_source")
    |> Enum.reject(fn file -> file == ".gitignore" end)
  end

  def load_gup_data(count \\ 1_000_000) do
    get_gup_file_names()
    |> Enum.take(count)
    # read all files in list
    |> Enum.map(fn file -> File.read!("../data/_source/" <> file) end)
    # parse json
    |> Enum.map(fn json -> Jason.decode!(json) end)
    # remap fields
    |> Enum.map(fn item -> remap_fields(item) end)
    |> Enum.map(fn item -> Map.put(item, "source", "gup") end)
    |> Enum.map(fn item -> Map.put(item, "id", "gup_" <> Integer.to_string(item["id"])) end)
  end

  def remap_fields(publication) do
    publication
    |> Map.put("authors", strip_authors(publication["authors"]))
  end


  def strip_authors([]), do: []
  def strip_authors(nil), do: []
  def strip_authors(authors) do
    authors
    |> Enum.map(fn author ->
      %{
        "id" => author["id"],
        "name" => get_full_name(author["first_name"], author["last_name"]),
        "x-account" => get_x_account(author["identifiers"]),
        "departments" => get_departments(author["departments"])
      }
    end)
  end

  def get_full_name(nil, nil), do: ""
  def get_full_name(nil, last_name), do: last_name
  def get_full_name(first_name, nil), do: first_name
  def get_full_name(first_name, last_name), do: first_name <> " " <> last_name



  def get_x_account([]), do: nil

  def get_x_account(identifiers) do
    identifiers
    |> Enum.find(fn identifier -> identifier["source_name"] == "xkonto" end)
    |> case do
      nil -> ""
      map -> Map.get(map, "value")
    end
  end

  def get_departments([]), do: nil
  def get_departments(department) do
   %{
      "id" => department["id"],
      "name" => department["name"],
      "faculty" => get_faculty(department["faculty"]),
   }
  end

  def get_faculty(faculty) do
    %{
      "id" => faculty["id"],
      "name" => faculty["name"]
    }
  end

  def check_env(var_name) do
    System.get_env(var_name)
    |> IO.inspect(label: "#{var_name} value")
  end
end
