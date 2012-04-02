require 'test_helper'

class MainBoardControllerTest < ActionController::TestCase
  test "should get hello" do
    get :hello
    assert_response :success
  end

  test "should get error" do
    get :error
    assert_response :success
  end

  test "should get setup" do
    get :setup
    assert_response :success
  end

end
