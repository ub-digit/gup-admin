defmodule GupIndexManager.Resource.Gup do
  require Logger

  def gup_server_base_url() do
    System.fetch_env!("GUP_SERVER_BASE_URL")
  end

  def gup_backand_api_key() do
    System.fetch_env!("GUP_API_KEY")
  end

  def next_gup_id_url() do
    "#{gup_server_base_url()}/v1/people/get_next_id?api_key=#{gup_backand_api_key()}"
  end

  def send_updated_data_url(id) do
    "#{gup_server_base_url()}/v1/people/#{id}?api_key=#{gup_backand_api_key()}"
  end


  def update_gup({:error, error, error_log_data}), do: {:error, error, error_log_data}

  def update_gup({:ok, person_data, actions}), do: update_gup(person_data)
  def update_gup(person_data) do
    compose_updated_data(person_data)
    |> send_updated_data_to_gup()
    {:ok, person_data}
  end



  def get_next_gup_id() do
    Logger.debug("IM:Gup.acquire_gup_person_id")
    HTTPoison.get(next_gup_id_url(), [{"Content-Type", "application/json"}])
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body |> Jason.decode!() |> Map.get("id") |> convert_to_integer()
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  def convert_to_integer(val) when is_bitstring(val), do: String.to_integer(val)
  def convert_to_integer(val) when is_integer(val), do: val
  def convert_to_integer(_), do: nil


  def compose_updated_data(person_as_a_map) do
    names =  Map.get(person_as_a_map, "names")
    identifiers = Map.get(person_as_a_map, "identifiers")
    names
    |> Enum.reduce([], fn name, acc ->
      p = {%{
        "person" => %{
          "first_name" => name["first_name"],
          "last_name" => name["last_name"],
          "year_of_birth" => person_as_a_map["year_of_birth"],
          "xaccount" => get_xaccount(identifiers)
        }
      }, name["gup_person_id"]}
        acc ++ [p]
    end)
  end


  def get_xaccount(identifiers) do
    IO.inspect(identifiers, label: "IDENTIFIERS")
    val = Enum.find(identifiers, fn identifier -> identifier["code"] == "X_ACCOUNT" end)
    case val do
      nil -> nil
      _ -> val |> Map.get("value", nil)
    end
  end

  def send_updated_data_to_gup(data) do
      # Enum.each(data, fn {peroson, id} -> IO.inspect(id, label: "ID") end)
    Enum.each(data, fn {person, id} ->
      Logger.debug("ADDRESS: #{send_updated_data_url(id)}")
      Logger.debug("Attempting to send updated data to Gup for person: #{inspect(person)} with id: #{id}")
      # HTTPoison.post(send_updated_data_url(id), person, [{"Content-Type", "application/json"}])
      HTTPoison.put(send_updated_data_url(id), person |> Jason.encode!(), [{"Content-Type", "application/json"}])
      |> case do
        # _ -> Logger.debug("Successfully updated person with id: #{id}")
        {:ok, %HTTPoison.Response{status_code: 200}} -> Logger.debug("Successfully updated person with id: #{id}")
        {:ok, %HTTPoison.Response{status_code: 404}} -> Logger.error("Person with id: #{id} not found")
        {:error, %HTTPoison.Error{reason: reason}} -> Logger.error("Error updating person with id: #{id}. Reason: #{reason}")
      end
    end)
  end
end
