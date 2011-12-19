require File.dirname(__FILE__) + '/../test_helper'

class PileTest < ActiveSupport::TestCase
  should belong_to :game
  should have_many :cards

  context "with game created" do
    setup do
      @game = Factory(:fixed_game)
    end
    
    should "return class from type" do
      @pile = Factory(:pile, :game => @game)
      assert_equal Intrigue::GreatHall, @pile.card_class
    end
	
    should validate_uniqueness_of(:card_type).scoped_to(:game_id).with_message(/Kingdom cards must be different/)
  end
end
