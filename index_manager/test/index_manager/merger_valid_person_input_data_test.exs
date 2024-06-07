# defmodule GupIndexManager.Resource.Persons.ValidPersonInputDataTest do
#   use ExUnit.Case
#   alias GupIndexManager.Resource.Persons.Merger

#   test "Assert valid person input data" do
#     person_input_data = %{
#       first_name: "John",
#       last_name: "Doe",
#       id: "123"
#     }

#     assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}

#     person_input_data = %{
#       x_account: "123"
#     }

#     assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}

#     person_input_data = %{
#       admin_id: "123"
#     }

#     assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}

#     person_input_data = %{}

#     assert Merger.merge(person_input_data) == {:error, "The person_input_data does not meet the minimum requirements"}



#   end

# end
