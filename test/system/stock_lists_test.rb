require "application_system_test_case"

class StockListsTest < ApplicationSystemTestCase
  setup do
    @stock_list = stock_lists(:one)
  end

  test "visiting the index" do
    visit stock_lists_url
    assert_selector "h1", text: "Stock Lists"
  end

  test "creating a Stock list" do
    visit stock_lists_url
    click_on "New Stock List"

    fill_in "Description", with: @stock_list.description
    fill_in "Name", with: @stock_list.name
    fill_in "User", with: @stock_list.user_id
    click_on "Create Stock list"

    assert_text "Stock list was successfully created"
    click_on "Back"
  end

  test "updating a Stock list" do
    visit stock_lists_url
    click_on "Edit", match: :first

    fill_in "Description", with: @stock_list.description
    fill_in "Name", with: @stock_list.name
    fill_in "User", with: @stock_list.user_id
    click_on "Update Stock list"

    assert_text "Stock list was successfully updated"
    click_on "Back"
  end

  test "destroying a Stock list" do
    visit stock_lists_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Stock list was successfully destroyed"
  end
end
