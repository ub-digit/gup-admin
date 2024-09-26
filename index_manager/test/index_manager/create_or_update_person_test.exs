defmodule GupIndexManager.CreateOrUpdatePersonTest do
  use ExUnit.Case
  alias GupIndexManager.Resource.Persons.Merger

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
        |> MergeTestHelpers.add_name_forms([{"John", "Doe", nil}, {"John", "Doe", "123456"}])
        |> MergeTestHelpers.add_identifiers([{@code_x_account, @existing_x_account}])

      # elastic_data = [existing_person_data, existing_person2_data]
      elastic_data = [existing_person_data]

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
      assert Merger.merge(person_input_data) == {:error, "The person_input_data does not meet the minimum requirements"}
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
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      assert {:ok, _person_input_data, [{:add_name, _data_n1}, {:create_or_update_person}]} = Merger.merge(person_input_data)
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
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      # acquire_gup_id implies add_name after the gup_person_id is acquired
      assert {:ok, _person_input_data, [{:acquire_gup_id, _name_form}, {:create_or_update_person}]} = Merger.merge(person_input_data)
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
        |> MergeTestHelpers.clear_gup_admin_id()

      IO.inspect(person_input_data, label: "Person input data in test")
      # We only assert the correct actions are present in the result
      assert {:ok, _person_input_data, [{:update_name, _data_n1}, {:create_or_update_person}]} = Merger.merge(person_input_data)
    end

    ################################################################################################

    # incoming data has same x_account as existing person and also new scopus id
    #@tag :skip
    test "merge existing user(x_account) with new data containing a new scopus id", setup_data do
      # input data
      person_input_data =
        setup_data[:existing_person_data]
        |> MergeTestHelpers.add_identifiers([{"SCOPUS_ID", "SCOPUS123"}])

      assert {:ok, _person_input_data, [{:add_identifier, _data}, {:create_or_update_person}]} = Merger.merge(person_input_data)
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
        |> MergeTestHelpers.clear_identifiers()
        |> MergeTestHelpers.add_identifiers(identifiers)
        |> MergeTestHelpers.clear_name_forms()
        |> MergeTestHelpers.add_name_forms([{"Jane", "Doe", "123456"}])

      IO.inspect(person_input_data, label: "Person input data in test")

      assert Merger.merge(person_input_data) == {:error, "Colliding ORCID and/or X_ACCOUNT"}
    end

     ################################################################################################

    # incoming data has same ORCID as existing person but a colliding X_ACCOUNT
    #@tag :skip
    test "merge existing user (orcid) with colliding X_ACCOUNT",
         setup_data do
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

      assert Merger.merge(person_input_data) == {:error, "Colliding ORCID and/or X_ACCOUNT"}
    end
  end
end
