defmodule GupIndexManager.Resource.Persons.Merger2 do
  alias GupIndexManager.Resource.Persons.Merger.InputValidator
  alias GupIndexManager.Resource.Persons.Merger.DataSanitizer
  alias GupIndexManager.Resource.Persons.Merger.UserIndexLookup
  alias GupIndexManager.Resource.Persons.Merger.NameForms
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  alias GupIndexManager.Resource.Persons.Merger.Actions
  require Logger

  def merge(meta_data) do

    IO.inspect("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx")
    with {:ok, meta_data} <- InputValidator.validate(meta_data),
         {:ok, meta_data} <- DataSanitizer.sanitize_data(meta_data),
         {:ok, meta_data, possible_candidates} <- UserIndexLookup.lookup(meta_data), # {:ok, data, existing_data} or {:ok, data, []}
         {:ok, meta_data, possible_candidates} <- NameForms.set_primary_name({meta_data, possible_candidates}),
         {:ok, meta_data, possible_candidates} <- Identifiers.colliding_identifiers({meta_data, possible_candidates}),
         {:ok, data, actions} <- Actions.generate_actions({meta_data, possible_candidates})
         do

          IO.inspect("OK, data, actions: #{inspect(actions, pretty: true)}")
          {:ok, data, actions}
    else
      {:error, :invalid_input_data, meta_data} -> {:error, :invalid_input_data, meta_data}
    end

    #  with {true, input_data} <- InputValidator.validate(input_data) do
    #     meta_data = input_data
    #     meta_data
    #     |> DataSanitizer.sanitize_data()
    #     |> UserIndexLookup.lookup() # {true, data, existing_data} or {false, data, []
    #     |> NameForms.set_primary_name()
    #     |> Identifiers.colliding_identifiers()
    #     |> Actions.generate_actions()
    #     |> tap_it("after colliding_identifiers")
    #  else
    #     {false, input_data} ->
    #       Logger.error("Input data validation failed: #{inspect(input_data, pretty: true)}")
    #       {:error, "Input data does not meet minimum requirements", input_data}
    #  end
  end

  # Helper function for debugging
  def tap_it(data, msg \\ "") do
    Logger.debug("#{msg}: #{inspect(data, pretty: true)}")
    data
  end

  # Test data for debugging.
  # delete this when done.

  def test_data do
    %{
      "id" => "123",
      "names" => [
        %{ "last_name" => "Smith", "primary" => true},
        %{"first_name" => "John", "last_name" => "Smith"}
      ]
    }
  end
end
