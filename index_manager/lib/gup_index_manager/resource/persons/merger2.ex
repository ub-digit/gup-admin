defmodule GupIndexManager.Resource.Persons.Merger2 do
  alias GupIndexManager.Resource.Persons.Merger.InputValidator
  alias GupIndexManager.Resource.Persons.Merger.DataSanitizer
  alias GupIndexManager.Resource.Persons.Merger.UserIndexLookup
  alias GupIndexManager.Resource.Persons.Merger.NameForms
  alias GupIndexManager.Resource.Persons.Merger.Identifiers
  alias GupIndexManager.Resource.Persons.Merger.Actions
  require Logger

  def merge(meta_data) do
    with {:ok, meta_data} <- InputValidator.validate(meta_data),
         {:ok, meta_data} <- DataSanitizer.sanitize_data(meta_data),
         {:ok, meta_data, possible_candidates} <- UserIndexLookup.lookup(meta_data), # {:ok, data, existing_data} or {:ok, data, []}
         {:ok, meta_data, possible_candidates} <- NameForms.set_primary_name({meta_data, possible_candidates}),
         {:ok, meta_data, possible_candidates} <- Identifiers.colliding_identifiers({meta_data, possible_candidates}),
         {:ok, data, actions} <- Actions.generate_actions({meta_data, possible_candidates})
         do
          Logger.debug("Merge result - data: #{inspect(data)}, actions: #{inspect(actions)}")
          {:ok, data, actions}

    else
      {:error, :invalid_input_data, meta_data} -> {:error, :invalid_input_data, meta_data} |> IO.inspect(label: "INVALID_INPUT_DATA_ERROR_IN_MERGE")
      {:error, reason, {meta_data, possible_candidates}} -> {:error, reason, {meta_data, possible_candidates}} |> IO.inspect(label: "ERROR IN MERGE")
      error -> {:error, :unexpected_error, error} |> IO.inspect(label: "UNEXPECTED ERROR IN MERGE")
    end
  end

  # Helper function for debugging
  def tap_it(data, msg \\ "") do
    Logger.debug("#{msg}: #{inspect(data, pretty: true)}")
    data
  end


end
