require "test_helper"

class DisksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @disk = disks(:one)
  end

  test "should get index" do
    get disks_url
    assert_response :success
  end

  test "should get new" do
    get new_disk_url
    assert_response :success
  end

  test "should create disk" do
    assert_difference("Disk.count") do
      post disks_url, params: { disk: { artist: @disk.artist, description: @disk.description, format: @disk.format, price: @disk.price, state: @disk.state, stock: @disk.stock, title: @disk.title, year: @disk.year } }
    end

    assert_redirected_to disk_url(Disk.last)
  end

  test "should show disk" do
    get disk_url(@disk)
    assert_response :success
  end

  test "should get edit" do
    get edit_disk_url(@disk)
    assert_response :success
  end

  test "should update disk" do
    patch disk_url(@disk), params: { disk: { artist: @disk.artist, description: @disk.description, format: @disk.format, price: @disk.price, state: @disk.state, stock: @disk.stock, title: @disk.title, year: @disk.year } }
    assert_redirected_to disk_url(@disk)
  end

  test "should destroy disk" do
    assert_difference("Disk.count", -1) do
      delete disk_url(@disk)
    end

    assert_redirected_to disks_url
  end
end
