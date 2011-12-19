require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :email
  should validate_format_of(:email).with("user+throwaway@subdom.example.com").with_message(/valid email address/)
  should validate_presence_of(:hashed_password)
  should validate_confirmation_of :password
  
  
  should "be able to create a user" do
    assert_nothing_raised do
      Factory(:user)
    end
  end
  
  should have_many(:players).dependent :destroy
  should have_many(:games).through :players
  should have_one :ranking
  should have_one :settings
  
  context "with created user" do
    setup do
      @user = Factory(:user)
    end
    
    should validate_uniqueness_of :name
    should validate_uniqueness_of :email
  
    should "be able to authenticate with correct password" do
      auth = User.authenticate(@user.name, @user.password)
      assert_equal @user, auth
    end
    
    should "not be able to authenticate with incorrect password" do
      auth = User.authenticate(@user.name, @user.password + "fake")
      assert_nil auth
    end
    
    should "be able to reset to random password" do
      qrand(0,-1,22,14,24,15,24,16)
      
      old_pass = @user.password
      @user.reset_password
      
      auth = User.authenticate(@user.name, old_pass)
      assert_nil auth
      auth = User.authenticate(@user.name, "a9zr3s3t")
      assert_equal @user, auth
    end
    
    should "have settings" do
      assert_not_nil @user.settings
    end
    
    should "have inited ranking" do
      assert_not_nil @user.ranking
      attribs = @user.ranking.attributes
      %w<num_played num_won total_normalised_pos total_score last_num_won last_total_norm_pos last_total_score>.each do |field|
        assert_equal 0, attribs[field]
      end
      %w<result_elo score_elo last_result_elo last_score_elo>.each do |field|
        assert_equal 1600, attribs[field]
      end
    end  
    
  end
  
end
