require "test_helper"

class CartGuidesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get cart_guides_create_url
    assert_response :success
  end

  test "should get destroy" do
    get cart_guides_destroy_url
    assert_response :success
  end
end
