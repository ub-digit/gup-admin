alias GupIndexManager.Resource.Persons.Merger.InputValidator
alias GupIndexManager.Resource.Persons.Merger.DataSanitizer
alias GupIndexManager.Resource.Persons.Merger.UserIndexLookup
alias GupIndexManager.Resource.Persons.Merger.NameForms
alias GupIndexManager.Resource.Persons.Merger.Identifiers
alias GupIndexManager.Resource.Persons.Merger.Actions
require Logger

defmodule GupIndexManager.Resource.Persons.Merger2 do
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  def merge(input_data) do
     with {true, input_data} <- InputValidator.validate(input_data) do
        meta_data = input_data
        meta_data
        |> DataSanitizer.sanitize_data()
        |> UserIndexLookup.lookup() # {true, data, existing_data} or {false, data, []
        |> NameForms.set_primary_name()
        |> Identifiers.colliding_identifiers()
        |> Actions.generate_actions()
        |> tap_it("after colliding_identifiers")

     else
        {false, input_data} ->
          Logger.error("Input data validation failed: #{inspect(input_data, pretty: true)}")
          {:error, "Input data does not meet minimum requirements", input_data}
     end
  end

  # Helper function for debugging
  def tap_it(data, msg \\ "") do
    Logger.debug("#{msg}: #{inspect(data, pretty: true)}")
    data
  end


  def test_data do
    %{
      "names" => [
        %{"first_name" => "John", "last_name" => "Smith", "primary" => true},
        %{"first_name" => "John", "last_name" => "Smith"}
      ],
      "identifiers" => [
        %{"code" => "ORCID", "value" => "0000-0000-0000-0000"},
        %{"code" => "XA", "value" => "ABC"}
      ]

    }

  end
end
