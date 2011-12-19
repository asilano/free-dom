require File.dirname(__FILE__) + '/../test_helper'

class ChatTest < ActiveSupport::TestCase
  should belong_to :game
  should belong_to :player
  should belong_to :turn_player
end
