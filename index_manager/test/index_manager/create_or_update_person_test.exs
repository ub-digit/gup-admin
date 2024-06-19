defmodule GupIndexManager.CreateOrUpdatePersonTest do
  use ExUnit.Case
  alias GupIndexManager.Resource.Persons.Merger

  @existing_x_account "xb123"
  @existing_orcid "orcid123"
  describe "Merge person with some form of identifier" do

    setup do
      # clear elastic index
      MergeTestHelpers.clear_index()

      # generate existing person data
      existing_person_data =
        MergeTestHelpers.generate_person_data()
        |> MergeTestHelpers.set_gup_admin_id("100")
        |> MergeTestHelpers.add_name_forms([{"John", "Doe", nil}])
        |> MergeTestHelpers.add_identifiers([{"X_ACCOUNT", @existing_x_account}, {"ORCID", @existing_orcid}])
        elastic_data = [existing_person_data]

        # index data
        MergeTestHelpers.index_data(elastic_data)

        # return data for test
        [existing_person_data: existing_person_data]
    end

    # Incoming data dose not meet the minimun requirements

    test "Faulty input data" do
      person_input_data = %{}
      assert Merger.merge(person_input_data) == {:error, "The person_input_data does not meet the minimum requirements"}
    end

    # incoming data meets the minimum requirements and person does not exist in the index
    test "Create new person", setup_data do
      person_input_data =  MergeTestHelpers.generate_person_data()
      |> MergeTestHelpers.add_name_forms([{"John", "Doe", "123456"}])
      |> MergeTestHelpers.add_identifiers([{"X_ACCOUNT", "new_x_account_123"}])
      assert {:ok, _person_input_data, [{:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    # incoming data has same x_account as existing person and but new name
    test "Merge existing user with new data containing a new name", setup_data do
      # input data
      person_input_data = setup_data[:existing_person_data]
      # |> MergeTestHelpers.clear_name_forms()
      |> MergeTestHelpers.add_name_forms([{"Jane", "Doe", "123456"}, {"John", "Doe", nil}, {"Fred", "Ronny", "12333456"}])
      # We only assert the correct actions are present in the result
      assert {:ok, _person_input_data, [{:add_name, _data_n1}, {:add_name, _data_n2}, {:create_or_update_person}]} = Merger.merge(person_input_data)
      # IO.inspect(test_data)
      IO.puts("---------------------------- test completed ----------------------------")
    end

    # incoming data has same x_account as existing person and also new scopus id
    test "merge existing user with new data containing a new scopus id", setup_data do
      # input data
      person_input_data = setup_data[:existing_person_data]
      |> MergeTestHelpers.add_identifiers([{"SCOPUS_ID", "SCOPUS123"}])
      # |> IO.inspect(label: "INPUT DATA MERGE IDENTIFIERS")
      assert {:ok, _person_input_data, [{:add_identifier, _data}, {create}]} = Merger.merge(person_input_data)
    end

    # incoming data has same x_account as existing person but a different ORCID
    @tag :skip
    test "merge existing user that has an orcid with new data containing a new ORCID", setup_data do
      # input data
      person_input_data = setup_data[:existing_person_data]
      |> MergeTestHelpers.clear_identifiers()
      |> MergeTestHelpers.add_identifiers([{"ORCID", "ORCID12_new3"}, {"X_ACCOUNT", @existing_x_account}])
      # |> IO.inspect(label: "INPUT DATA MERGE IDENTIFIERS")
      assert Merger.merge(person_input_data) == {:error, "Colliding ORCID's"}
    end
    #   assert Merger.merge(person_input_data) == {:ok, [{:create_person, person_input_data}]}
    #   # assert Merger.merge(person_input_data) == {:ok, [{:add_identifier, person_input_data}]}
    #   IO.puts("---------------------------- test completed ----------------------------")

    # end
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
