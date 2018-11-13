require 'test_helper'

class StockListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stock_list = stock_lists(:one)
  end

  test "should get index" do
    get stock_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_stock_list_url
    assert_response :success
  end

  test "should create stock_list" do
    assert_difference('StockList.count') do
      post stock_lists_url, params: { stock_list: { description: @stock_list.description, name: @stock_list.name, user_id: @stock_list.user_id } }
    end

    assert_redirected_to stock_list_url(StockList.last)
  end

  test "should show stock_list" do
    get stock_list_url(@stock_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_stock_list_url(@stock_list)
    assert_response :success
  end

  test "should update stock_list" do
    patch stock_list_url(@stock_list), params: { stock_list: { description: @stock_list.description, name: @stock_list.name, user_id: @stock_list.user_id } }
    assert_redirected_to stock_list_url(@stock_list)
  end

  test "should destroy stock_list" do
    assert_difference('StockList.count', -1) do
      delete stock_list_url(@stock_list)
    end

    assert_redirected_to stock_lists_url
  end
end
