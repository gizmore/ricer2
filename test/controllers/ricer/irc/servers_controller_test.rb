require 'test_helper'

class Ricer::Irc::ServersControllerTest < ActionController::TestCase
  setup do
    @ricer_irc_server = ricer_irc_servers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ricer_irc_servers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ricer_irc_server" do
    assert_difference('Ricer::Irc::Server.count') do
      post :create, ricer_irc_server: {  }
    end

    assert_redirected_to ricer_irc_server_path(assigns(:ricer_irc_server))
  end

  test "should show ricer_irc_server" do
    get :show, id: @ricer_irc_server
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ricer_irc_server
    assert_response :success
  end

  test "should update ricer_irc_server" do
    patch :update, id: @ricer_irc_server, ricer_irc_server: {  }
    assert_redirected_to ricer_irc_server_path(assigns(:ricer_irc_server))
  end

  test "should destroy ricer_irc_server" do
    assert_difference('Ricer::Irc::Server.count', -1) do
      delete :destroy, id: @ricer_irc_server
    end

    assert_redirected_to ricer_irc_servers_path
  end
end
