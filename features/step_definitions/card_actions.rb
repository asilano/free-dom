When(/^(\w*?) plays? #{SingleCard}$/) do |name, kind|
  name = 'Alan' if name == 'I'
  assert_contains @hand_contents[name], kind
  card = @test_players[name].cards.hand.first(:conditions => ['type = ?', CARD_TYPES[kind].name])
  assert_not_nil card

  @hand_contents[name].delete_first(kind)
  if CARD_TYPES[kind].is_duration?
    @enduring_contents[name] << kind
  else
    @play_contents[name] << kind
  end
  parent_act = @test_players[name].pending_actions.active.first
  assert_match /play_action/, parent_act.expected_action

  card_ix = @test_players[name].cards.hand.index {|c| c.type == card.type}
  @test_players[name].play_action(:card_index => card_ix, :pa_id => parent_act.id)

  # Playing the card is likely to do something. Skip checking this step
  @skip_card_checking = 1 if @skip_card_checking == 0
end

When(/^(\w*?) stops? playing actions$/) do |name|
  name = 'Alan' if name == 'I'
  parent_act = @test_players[name].pending_actions.active.first
  assert_match /play_action/, parent_act.expected_action

  @test_players[name].play_action(:nil_action => "Leave Action Phase", :pa_id => parent_act.id)
end

When(/^(\w*?) plays? #{SingleCard} as treasure$/) do |name, kind|
  name = 'Alan' if name == 'I'
  assert_contains @hand_contents[name], kind
  card = @test_players[name].cards.hand.first(:conditions => ['type = ?', CARD_TYPES[kind].name])
  assert_not_nil card

  @hand_contents[name].delete_first(kind)
  @play_contents[name] << kind
  parent_act = @test_players[name].pending_actions.active.first
  assert_match /play_treasure/, parent_act.expected_action

  card_ix = @test_players[name].cards.hand.index {|c| c.type == card.type}
  @test_players[name].play_treasure(:card_index => card_ix, :pa_id => parent_act.id)

  # Playing the card is likely to do something. Skip checking this step
  @skip_card_checking = 1 if @skip_card_checking == 0
end

When(/^(\w*?) stops? playing treasures$/) do |name|
  name = 'Alan' if name == 'I'

  parent_act = @test_players[name].pending_actions.active.first
  assert_match /play_treasure/, parent_act.expected_action

  @test_players[name].play_treasure(:nil_action => "Stop Playing Treasures", :pa_id => parent_act.id)
end

When(/^(\w*?) plays? simple treasures$/) do |name|
  name = 'Alan' if name == 'I'

  parent_act = @test_players[name].pending_actions.active.first
  assert_match /play_treasure/, parent_act.expected_action

  @test_players[name].play_treasure(:nil_action => "Play Simple Treasures", :pa_id => parent_act.id)

  # Skip checking this step, so the feature can move the cards
  @skip_card_checking = 1 if @skip_card_checking == 0
end

When(/(.*) moves? (.*) from (.*) to (.*)/) do |name, kind, from, to|
  assert_not_equal "deck", from
  assert_not_equal "deck", to

  name = "Alan" if name == "I"
  card = @test_players[name].cards.where(:location => from, :type => CARD_TYPES[kind].to_s)[0]
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

When(/^(\w*?) buys? #{SingleCard} expecting side-effects$/) do |name, kind|
  @skip_card_checking = 1 if @skip_card_checking == 0
  steps "When #{name} buys #{kind}"
end

When(/^(\w*?) buys? #{SingleCard}$/) do |name, kind|
  name = 'Alan' if name == 'I'

  assert_contains @test_game.piles.map{|p| p.card_class.readable_name}, kind
  pile = @test_game.piles.first(:conditions => ['card_type = ?', CARD_TYPES[kind].name])
  assert_not_nil pile

  parent_act = @test_players[name].pending_actions.active.first
  assert_match /buy/, parent_act.expected_action

  pile_ix = @test_game.piles.index {|p| p.card_type == pile.card_type}
  # Need to ensure player has correct record of cash from database, or buy fails
  @test_players[name].reload.buy(:pile_index => pile_ix, :pa_id => parent_act.id)
end

When(/^(\w*?) stops? buying cards$/) do |name|
  name = 'Alan' if name == 'I'
  parent_act = @test_players[name].pending_actions(true).active.first
  assert_match /buy/, parent_act.expected_action

  @test_players[name].buy(:nil_action => "Buy no more", :pa_id => parent_act.id)
end