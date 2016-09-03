require 'test_helper'

class TrainersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trainers_index_url
    assert_response :success
  end

end
