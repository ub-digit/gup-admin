defmodule GupIndexManager.CreateOrUpdatePersonTest do
  use ExUnit.Case
  alias GupIndexManager.Resource.Persons.Merger

  describe "Merge person with some form of identifier" do

    setup do
      # clear elastic index
      MergeTestHelpers.clear_index()

      # generate existing person data
      existing_person_data =
        MergeTestHelpers.generate_person_input_data()
        |> MergeTestHelpers.add_name_forms([{"John", "Doe", nil}])
        |> MergeTestHelpers.add_name_forms([{"Leify", "Doe", nil}])
        |> MergeTestHelpers.add_identifiers([{"scopus_id", "some_scopus_id"}])
        elastic_data = [existing_person_data]

        # index data
        MergeTestHelpers.index_data(elastic_data)

        # return data for test
        [existing_person_data: existing_person_data]
    end

    # Premise:
    # Person exists in gup admin (in elastic and db)
    # Person has a scopus id
    # input data has a different scopus id


    test "merge existing user with new data containing a different scopus id", setup_data do
      # input data
      person_input_data = setup_data[:existing_person_data]
      |> MergeTestHelpers.clear_identifiers()
      |> MergeTestHelpers.add_identifiers([{"scopus_id", "new_scopus_id"}])


      assert Merger.merge(person_input_data) == {:ok, [{:add_identifier, person_input_data}]}
      # assert Merger.merge(person_input_data) == {:ok, [{:add_identifier, person_input_data}]}
      IO.puts("test completed")

    end
    # test "has x account" do
    #   person_input_data = %{
    #     x_account: "123"
    #   }
    #   assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}
    # end

    # test "has scopus id" do
    #   person_input_data = %{
    #     x_account: "123"
    #   }
    #   assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}
    # end

    # test "merge person with same xaccount and different ORCID" do
    #   elastic_data = [generate_person_input_data(
    #   [
    #     %{
    #             "start_date" => "2019-01-01T00:00:00+01:00",
    #             "end_date" => "2019-12-31T00:00:00+01:00",
    #             "gup_person_id" => "100",
    #             "first_name" => "John",
    #             "last_name" => "Doe"
    #           }
    #   ]

    #   )]

    #   index_data(elastic_data)

    #   assert true


    # end
  end







end
