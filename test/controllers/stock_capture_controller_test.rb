require 'test_helper'

class StockCaptureControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stock_capture_index_url
    assert_response :success
  end

end
