require File.dirname(__FILE__) + '/../test_helper'

class CardTest < ActiveSupport::TestCase
  should belong_to :player
  should belong_to :game
  should belong_to :pile
    
end
