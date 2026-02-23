defmodule GupIndexManager.Resource.Persons.Merger2 do
  alias GupIndexManager.Resource.Persons.Merger.InputValidator
  alias GupIndexManager.Resource.Persons.Merger.DataSanitizer
  alias GupIndexManager.Resource.Persons.Merger.UserIndexLookup
  alias GupIndexManager.Resource.Persons.Merger.NameForms
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  alias GupIndexManager.Resource.Persons.Merger.Actions
  require Logger

  def merge(meta_data) do
    IO.inspect("MERGE STARTED")
    with {:ok, meta_data} <- InputValidator.validate(meta_data),
         {:ok, meta_data} <- DataSanitizer.sanitize_data(meta_data),
         {:ok, meta_data, possible_candidates} <- UserIndexLookup.lookup(meta_data), # {:ok, data, existing_data} or {:ok, data, []}
         {:ok, meta_data, possible_candidates} <- NameForms.set_primary_name({meta_data, possible_candidates}),
         {:ok, meta_data, possible_candidates} <- Identifiers.colliding_identifiers({meta_data, possible_candidates}),
         {:ok, data, actions} <- Actions.generate_actions({meta_data, possible_candidates})
         do
          actions = case actions do
            [{:create_or_update_person}] ->
              IO.inspect("NO ACTIONS NEEDED ABORT!ABORT! ABORT!")
              {:no_actions_needed}
            actions -> actions
          end
          IO.inspect("BLÖBLBLSLDLSD")
          {:ok, data, actions}

    else
      {:error, :invalid_input_data, meta_data} -> {:error, :invalid_input_data, meta_data}
      {:error, reason, {meta_data, possible_candidates}} -> {:error, reason, {meta_data, possible_candidates}}

    end
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
      "names" => [
        %{"first_name" => "Abel", "Kain" => "Smith"}
      ],
      "force_primary_name" => true,
      "identifiers" => [
        %{"code" => "CID", "value" => "flfllfsasaaaalf"},
      ]
    }
  end
end
