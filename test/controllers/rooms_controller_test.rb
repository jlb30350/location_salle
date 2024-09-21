require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get rooms_url
    assert_response :success
  end

  test "should get show" do
    room = rooms(:one)  # Assurez-vous d'avoir un fixture
    get room_url(room)
    assert_response :success
  end

  test "should get new" do
    get new_room_url
    assert_response :success
  end

  test "should create room" do
    post rooms_url, params: { room: { name: "New Room", description: "Nice room", price: 100 } }
    assert_response :redirect  # car en général, après création, il y a une redirection
  end

  test "should get edit" do
    room = rooms(:one)  # Assurez-vous d'avoir un fixture
    get edit_room_url(room)
    assert_response :success
  end

  test "should update room" do
    room = rooms(:one)
    patch room_url(room), params: { room: { name: "Updated Name" } }
    assert_response :redirect  # généralement, on redirige après la mise à jour
  end

  test "should destroy room" do
    room = rooms(:one)
    assert_difference('Room.count', -1) do
      delete room_url(room)
    end
    assert_response :redirect  # généralement redirigé vers index après suppression
  end
end
