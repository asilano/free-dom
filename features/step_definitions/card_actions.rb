When /I play (.*)/ do |kind|
  assert_contains @hand_contents[:fixed], kind
  card = @me.cards.hand.first(:conditions => ['type = ?', CARD_TYPES[kind].name])
  assert_not_nil card
  
  @hand_contents[:fixed].delete_at(@hand_contents[:fixed].index(kind))
  parent_act = @me.active_actions[0]
  assert_match /play_action/, parent_act.expected_action
  
  card_ix = @me.cards.hand.index {|c| c.type == card.type}
  @me.play_action(:card_index => card_ix)
end

When /I move (.*) from (.*) to (.*)/ do |kind, from, to|
  card = @me.cards.where(:location => from, :type => CARD_TYPES[kind].to_s)[0]
  card.location = to
  card.save!
end