defmodule GupIndexManager.Resource.Gup do
  require Logger
  @people "people"
  @departments "departments"

  def people(), do: @people
  def departments(), do: @departments


  def gup_server_base_url() do
    System.fetch_env!("GUP_SERVER_BASE_URL")
  end

  def gup_backand_api_key() do
    System.fetch_env!("GUP_API_KEY")
  end

  def next_gup_id_url(entity_type) do
    "#{gup_server_base_url()}/v1/#{entity_type}/get_next_id?api_key=#{gup_backand_api_key()}"
  end

  def send_updated_data_url(id, entity_type = @people) do
    "#{gup_server_base_url()}/v1/#{entity_type}/#{id}?api_key=#{gup_backand_api_key()}"
  end

  def send_updated_data_url(_entity_type = @departments) do
    # IO.inspect("------------------------------------- GET URL FOR GUP ORGANISATIONS -------------------------------------")
    "#{gup_server_base_url()}/v1/organisations?api_key=#{gup_backand_api_key()}"
  end

  def update_gup({:error, error, error_log_data}), do: {:error, error, error_log_data}
  def update_gup(entity_data, _initial_load = true) do
    {:ok, entity_data}
 end
  def update_gup({:ok, entity_data, _actions}, initial_load, entity_type), do: update_gup(entity_data, initial_load, entity_type)
  def update_gup(entity_data, _initial_load = false, entity_type) do
    compose_updated_data(entity_data, entity_type)
    |> send_updated_data_to_gup(entity_type)
    {:ok, entity_data}
  end

  def get_next_gup_id(entity_type) do
    Logger.debug("IM:Gup.acquire_gup_entity_id for entity_type: #{entity_type}")
    HTTPoison.get(next_gup_id_url(entity_type), [{"Content-Type", "application/json"}])
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body |> Jason.decode!() |> Map.get("id") |> convert_to_integer()
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:ok, %HTTPoison.Response{status_code: 500, body: body}} -> IO.inspect("Got 500")

    end
  end

  def convert_to_integer(val) when is_bitstring(val), do: String.to_integer(val)
  def convert_to_integer(val) when is_integer(val), do: val
  def convert_to_integer(_), do: nil

  def compose_updated_data(entity_data, @people), do: compose_updated_person_data(entity_data)
  def compose_updated_data(entity_data, @departments), do: entity_data

  def compose_updated_person_data(person_as_a_map) do
    names =  Map.get(person_as_a_map, "names")
    identifiers = Map.get(person_as_a_map, "identifiers")
    names
    |> Enum.reduce([], fn name, acc ->
      p = {%{
        "person" => %{
          "first_name" => name["first_name"],
          "last_name" => name["last_name"],
          "year_of_birth" => person_as_a_map["year_of_birth"],
          "identifiers" => identifiers
        }
      }, name["gup_person_id"]}
        acc ++ [p]
    end)
  end

  def send_updated_data_to_gup(data, _entity_type = @people) do
    Enum.each(data, fn {person, id} ->
      Logger.debug("Attempting to send updated data to Gup for person: #{inspect(person)} with id: #{id}")
      HTTPoison.put(send_updated_data_url(id, @people), person |> Jason.encode!(), [{"Content-Type", "application/json"}])
      |> case do
        {:ok, %HTTPoison.Response{status_code: 200}} -> Logger.debug("Successfully updated person with id: #{id}")
        {:ok, %HTTPoison.Response{status_code: 404}} -> Logger.error("Person with id: #{id} not found")
        {:error, %HTTPoison.Error{reason: reason}} -> Logger.error("Error updating person with id: #{id}. Reason: #{reason}")
      end
    end)
  end

  def send_updated_data_to_gup(data, _entity_type = @departments) do
    IO.inspect("------------------------------------- SEND UPDATED DATA TO GUP ORGANISATIONS ---------------------------------PPPPPPPPPPPPPPPPPPPPPP----")
    body = %{"organisations" => data}
    Logger.debug("Attempting to send updated data to Gup for department: #{inspect(body)}")
    HTTPoison.put(send_updated_data_url(@departments), body |> Jason.encode!(), [{"Content-Type", "application/json"}])
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200}} -> Logger.debug("Successfully updated department data")
      {:ok, %HTTPoison.Response{status_code: 404}} -> Logger.error("Department not found")
      {:error, %HTTPoison.Error{reason: reason}} -> Logger.error("Error updating department data. Reason: #{reason}")
    end
  end

end
