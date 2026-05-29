require "test_helper"

class Backstore::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backstore_reports_index_url
    assert_response :success
  end

  test "should get metrics" do
    get backstore_reports_metrics_url
    assert_response :success
  end

  test "should get analysis" do
    get backstore_reports_analysis_url
    assert_response :success
  end
end
