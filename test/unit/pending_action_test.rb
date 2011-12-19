require File.dirname(__FILE__) + '/../test_helper'

class PendingActionTest < ActiveSupport::TestCase
  should belong_to :game
  should belong_to :player
  should belong_to :parent
  should have_many :children
  
  should "default text if absent" do
    @pa = Factory(:pending_action)
    assert_equal "Action which is expected", @pa.text
  end
  
  should "not default text if absent" do
    @pa = Factory(:pending_action, :text => "Hello")
    assert_equal "Hello", @pa.text     
  end
  
  should "maintain heirarchy" do
    @top = Factory(:pending_action)
    son = Factory(:pending_action, :expected_action => "son", :parent => @top, :player_id => 2)
		daughter = Factory(:pending_action, :expected_action => "daughter", :parent => @top, :player_id => 3)
		grandson = Factory(:pending_action, :expected_action => "grandson", :parent => son, :player_id => 2)
		granddaughter = Factory(:pending_action, :expected_action => "granddaughter", :parent => son, :player_id => nil)
    
    patt = <<EOF
---
>
  exp_re: /expected$/
  ply_id: 
  kids:
  >
    exp_re: /^son/
    ply_id: 2
    kids:
    >
      exp_re: /grandd/
      ply_id: 
      kids:
    >
      exp_re: /grands/
      ply_id: 2
      kids:
  >
    exp_re: /^daugh/
    ply_id: 3
    kids:
EOF
    
    assert_pend_acts_like(patt, [@top])
  end
end
