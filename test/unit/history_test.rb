require File.dirname(__FILE__) + '/../test_helper'

class HistoryTest < ActiveSupport::TestCase
  should belong_to :game
end
