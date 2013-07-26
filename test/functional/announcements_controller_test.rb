require 'test_helper'

class AnnouncementsControllerTest < ActionController::TestCase
  if false
    setup do
      @announcement = announcements(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create announcement" do
        post :create, announcement: @announcement

      assert_redirected_to announcement_path(assigns(:announcement))
    end

    test "should not expose show, edit, delete" do
      get :show
      assert_response :missing

      get :edit
      assert_response :missing

      put :update
      assert_response :missing

      delete :destroy
      assert_response :missing
    end
  end
end