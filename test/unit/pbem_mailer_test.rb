require File.dirname(__FILE__) + '/../test_helper'

class PbemMailerTest < ActionMailer::TestCase

  context "with user" do
    setup do
      @user = Factory(:user)
      ENV['CLOUDMAILIN_FORWARD_ADDRESS'] = "fwd@cloudmailin.com"
    end
    
    should "send game params email" do
      # Fix the order of BaseGame and Prosperity cards. We'll now pick the 7 cheapest 
      # Base cards, and the 3 cheapest Prosperity cards.
      qshuffle([(0...BaseGame.kingdom_cards.length).to_a, /expand_random_choices/],
                ['?', /expand_random_choices/],
                ['?', /expand_random_choices/],
                [(0...Prosperity.kingdom_cards.length).to_a, /expand_random_choices/])
      game = Factory.build(:dist_random_game)
      game.expand_random_choices      
      
      email = PbemMailer.deliver_game_params(@user, game)
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Confirm / Modify New Game Details", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Action: Create Game/, email.body)
      assert_match(/Username: #{@user.name}/, email.body)
      assert_match(/Name: #{game.name}/, email.body)
      assert_match(/Max Players: #{game.max_players}/, email.body)
      
      BaseGame.kingdom_cards[0,7].each do |card|
        assert_match(/Kingdom Card \d+: BaseGame - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      Prosperity.kingdom_cards[0,3].each do |card|
        assert_match(/Kingdom Card \d+: Prosperity - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      assert_match(/Include Platinum and Colony: #{game.plat_colony || 'rules'}/, email.body)
    end
  end
  
#  context "with game and user" do
#    setup do
#      stub_game(:create_game, :create_users)
#    end
#    
#    should "send game created email" do
#      todo
#    end
#    
#    should "send player joined email" do
#      todo
#    end
#    
#    should "send game started email" do
#      todo
#    end
#    
#    should "send action required email" do
#      todo
#    end
#   
#    should "send game update email" do
#      todo
#    end
#    
#    should "send game end email" do
#      todo
#    end
#  end
end
