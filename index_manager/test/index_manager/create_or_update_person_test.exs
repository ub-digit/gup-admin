defmodule GupIndexManager.CreateOrUpdatePersonTest do
  use ExUnit.Case
  alias ElixirSense.Providers.Expand
  alias GupIndexManager.Resource.Persons.Merger

  # TODO: Split into separate files. Index new data for each test and create new oinput data for each test.

  @existing_x_account "xb1111"
  @non_existing_x_account "xb9999"
  @code_x_account "X_ACCOUNT"
  @code_orcid "ORCID"
  @existing_orcid "orcid1111"
  @non_existing_orcid "orcid9999"
  @existing_gup_person_id "101010"
  @non_existing_gup_person_id "999999"

  describe "Merge person with some form of identifier" do
    ################################################################################################
    #
    #   Setup data for all tests in this module
    #
    ################################################################################################
    setup do
      # clear elastic index
      MergeTestHelpers.clear_index()

      # generate existing person data
      existing_person_data =
        MergeTestHelpers.generate_person_data()
        |> MergeTestHelpers.set_gup_admin_id("100")
        |> MergeTestHelpers.add_name_forms([{"Johnn", "Doe", @existing_gup_person_id}])
        |> MergeTestHelpers.add_identifiers([
          {@code_x_account, @existing_x_account},
          {@code_orcid, @existing_orcid}
        ])

      existing_person2_data =
        MergeTestHelpers.generate_person_data()
        |> MergeTestHelpers.set_gup_admin_id("101")
        |> MergeTestHelpers.add_name_forms([{"George", "Cloney", "222222"}])
        |> MergeTestHelpers.add_identifiers([{@code_orcid, @existing_orcid}, {"yada", "yada"}])

      elastic_data = [existing_person_data, existing_person2_data]
      #elastic_data = [existing_person_data]

      # index data
      MergeTestHelpers.index_data(elastic_data)

      # return data for test
      [existing_person_data: existing_person_data]
    end

    ################################################################################################
    #
    #   Tests
    #
    ################################################################################################

    # Incoming data does not meet the minimun requirements

    #@tag :skip
    test "check for faulty input data" do
      IO.puts("RUNNING FAULTY DATA TEST")
      # empty map representing the incoming data
      person_input_data = %{"names" => [%{"first_name" => "John", "last_name" => "Doe"}], "identifiers" => []}
      assert {:error, "The person_input_data does not meet the minimum requirements", _error_data} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data meets the minimum requirements and person does not exist in the index

    #@tag :skip
    test "Create new person", setup_data do
      IO.puts("RUNNING CREATE NEW PERSON TEST")

      person_input_data =
        MergeTestHelpers.generate_person_data()
        |> MergeTestHelpers.add_name_forms([{"John", "Doe", @non_existing_gup_person_id}])
        |> MergeTestHelpers.add_identifiers([{@code_x_account, @non_existing_x_account}])
      assert {:ok, _person_input_data, [{:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data has the same x_account as existing person
    # incoming data has has the same first and last name as existing person but different gup_person_id

    #@tag :skip
    test "Merge existing user with same name, but different gup_person_id", setup_data do
      # input data
      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"John", "Doe", @non_existing_gup_person_id}])
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers([{@code_x_account, @existing_x_account}])
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      assert {:ok, _primary_data, [{:add_name, _data_n1}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data has the same x_account as existing person
    # incoming data has a name form without gup_person_id, thus we need to acquire a new gup_person_id from gup

    #@tag :skip
    test "Merge existing user with data that is missing gup_person_id", setup_data do
      # input data
      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"Blenda", "Bobby", nil}])
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers([{@code_x_account, @existing_x_account}])
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      # acquire_gup_id implies add_name after the gup_person_id is acquired
      assert {:ok, _primary, [{:acquire_gup_id, _name_form}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

     ################################################################################################

    # incoming data has the same x_account as existing person
    # incoming data has has different first or last name as existing persons matching gup_person_id

    #@tag :skip
    test "Input data has same gup person id, but different first name", setup_data do
      # input data
      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"Johnny", "Doe", @existing_gup_person_id}])
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers([{@code_x_account, @existing_x_account}])
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      assert {:ok, _primary_data, [{:update_name, _data_n1}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data has same x_account as existing person and also new scopus id
    #@tag :skip
    test "merge existing user(x_account) with new data containing a new scopus id", setup_data do
      # input data

      person_input_data = setup_data[:existing_person_data]
      |> MergeTestHelpers.clear_gup_admin_id()
      |> MergeTestHelpers.clear_identifiers()
      |> MergeTestHelpers.add_identifiers([{"SCOPUS_ID", "SCOPUS123"}, {@code_x_account, @existing_x_account}])

      assert {:ok, _primary_data, [{:add_identifier, _data}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data has same x_account as existing person but a colliding ORCID
    #@tag :skip
    test "merge existing user (x_account) with colliding ORCID",
         setup_data do
      # input data
      identifiers = [
        {@code_x_account, @existing_x_account},
        {@code_orcid, @non_existing_orcid}
      ]

      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.clear_gup_admin_id()
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers(identifiers)
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"Jane", "Doe", "123456"}])

      IO.inspect(person_input_data, label: "Person input data in test")

      assert {:error, "Colliding ORCID and/or X_ACCOUNT", _error_data} = Merger.merge(person_input_data)
    end

     ################################################################################################

    # incoming data has same ORCID as existing person but a colliding X_ACCOUNT
    #@tag :skip
    test "merge existing user (orcid) with colliding X_ACCOUNT", setup_data do
      # input data
      identifiers = [
        {@code_x_account, @non_existing_x_account},
        {@code_orcid, @existing_orcid}
      ]

      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers(identifiers)
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"Jane", "Doe", "123456"}])

      IO.inspect(person_input_data, label: "Person input data in test")

      assert {:error, "Colliding ORCID and/or X_ACCOUNT", _error_data} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data:
    # - match one existing post on ORCID
    # - match one existing post on X_ACCOUNT
    # - has a new name with a non-existing gup__person_id
    #
    # Expected result:
    #   - add exixting name and identifiers fom existing person 2 to existing person 1
    #   - add new name to existing person 1
    #   - delete existing person 2
    #@tag :skip
    test "merge incoming data with multiple existing persons", setup_data do

      person_input_data = MergeTestHelpers.generate_person_data()
    |> MergeTestHelpers.add_name_forms([{"Johnny", "Cobra", @non_existing_gup_person_id}])
    |> MergeTestHelpers.clear_identifiers()
    |> MergeTestHelpers.add_identifiers([
      {@code_x_account, @existing_x_account},
      {@code_orcid, @existing_orcid}
    ])

    IO.inspect(person_input_data, label: "Person input data in test")
    res = Merger.merge(person_input_data)
    IO.inspect(res, label: "Result in test with multiple existing persons")
    assert {:ok, _primary_data, [{:add_name, _data_n1}, {:add_name, _data_n2}, {:add_identifier, _identifier_data}, {:delete_person, _id}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data:
    # - match one existing post on ORCID
    # - has a gup_admin_id that exists in index
    # - match ORCID on existing person with different gup_admin_id
    # Expected result:

    # @tag :skip
    # test "merge incoming data with existing person on ORCID and new gup_admin_id", setup_data do
    #   person_input_data = MergeTestHelpers.generate_person_data()
    #   |> MergeTestHelpers.add_name_forms([{"Johnny", "Cobra", @non_existing_gup_person_id}])
    #   |> MergeTestHelpers.add_identifiers([
    #     {@code_orcid, @existing_orcid}
    #   ])
    #   |> MergeTestHelpers.set_gup_admin_id("999")


    # end
    @tag :skip
    test "index data" do
      Experiment.add_data()
      assert true

    end
  end
end
