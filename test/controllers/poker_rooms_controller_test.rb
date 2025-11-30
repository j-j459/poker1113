require "test_helper"

class PokerRoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get poker_rooms_show_url
    assert_response :success
  end
end
