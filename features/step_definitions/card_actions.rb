When(/(.*) play(?:s)? (.*)/) do |name, kind|
  name = 'Alan' if name == 'I'
  assert_contains @hand_contents[name], kind
  card = @players[name].cards.hand.first(:conditions => ['type = ?', CARD_TYPES[kind].name])
  assert_not_nil card
  
  @hand_contents[name].delete_first(kind)
  @play_contents[name] << kind
  parent_act = @players[name].active_actions[0]
  assert_match /play_action/, parent_act.expected_action
  
  card_ix = @players[name].cards.hand.index {|c| c.type == card.type}
  @players[name].play_action(:card_index => card_ix)
  
  # Playing the card is likely to do something. Skip checking this step
  @skip_card_checking = 1 if @skip_card_checking == 0
end

When(/(.*) move(?:s)? (.*) from (.*) to (.*)/) do |name, kind, from, to|
  assert_not_equal "deck", from
  assert_not_equal "deck", to
  
  name = "Alan" if name == "I"
  card = @players[name].cards.where(:location => from, :type => CARD_TYPES[kind].to_s)[0]
  card.location = to
  card.save!
  
  if (%w<hand play discard enduring>.include? from)
    conts = instance_variable_get("@#{from}_contents")
    conts[name].delete_first(kind)
  end
  
  if (%w<hand play discard enduring>.include? to)
    conts = instance_variable_get("@#{to}_contents")
    conts[name] << kind
  end
end