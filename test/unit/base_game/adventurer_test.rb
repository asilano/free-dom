require File.dirname(__FILE__) + '/../../test_helper'

class BaseGame::AdventurerTest < ActiveSupport::TestCase
  should belong_to :player
  
  
end