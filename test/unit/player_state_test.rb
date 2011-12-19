require File.dirname(__FILE__) + '/../test_helper'

class PlayerStateTest < ActiveSupport::TestCase
  should belong_to :player
end
