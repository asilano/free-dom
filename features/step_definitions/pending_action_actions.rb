# Step for any control that requires you to make a choice in your hand; that is, process any controls[:hand] control
#
# Matches
#   I choose Estate in my hand
#   Bob chooses Estate, Copper in his hand
#   I choose Don't trash in my hand  // (Where "Don't trash" is the nil-action text)
When(/^(\w*?) chooses? (#{CardListNoCapture}|.*) in (?:his|my) hand$/) do |name, choices|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "No controls found in #{name}'s hand" if controls.length == 0
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end

  if Array(ctrl[:nil_action]).include? choices
    params[:nil_action] = choices
  else
    possibilities = player.cards.hand.map(&:readable_name)
    assert_not_empty possibilities

    kinds = choices.split(/,\s*/)
    if kinds.length == 1 && kinds[0] !~ /.* ?x ?\d*/
      params[key] = possibilities.index(kinds[0])
      assert_not_nil params[key], "Couldn't find #{kinds[0]} in hand (#{possibilities.inspect})"
    else
      params[key] = []
      kinds.each do |kind|
        num = 1
        card_name = kind
        if /(.*) ?x ?(\d+)/ =~ kind
          card_name = $1.rstrip
          num = $2.to_i
        end

        num.times do
          ix = possibilities.index(card_name)
          possibilities[ix] = nil

          params[key] << ix
        end
      end
    end
  end

  player.resolve(params)

  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a choice of revealed/peeked cards;
# that is, process any controls[:revealed] / controls[:peeked] control
#
# Matches
#   I choose my revealed Estate
#   Bob chooses his revealed Estate, Copper
#   I choose my peeked Province
#   I choose my revealed Don't trash // (Where "Don't trash" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (?:his|my) (revealed|peeked) (.*)$/) do |name, location, choice|
  name = "Alan" if name == "I"
  player = @test_players[name]

  location = location.to_sym

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[location]
  flunk "No controls found for #{name}'s peeked cards" if controls.length == 0
  flunk "Unimplemented multi-peek controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end

  if Array(ctrl[:nil_action]).include? choice
    params[:nil_action] = choice
  else
    if location == :revealed
      possibilities = player.cards.revealed.map(&:readable_name)
    elsif location == :peeked
      possibilities = player.cards.peeked.map(&:readable_name)
    else
      flunk "Unimplemented choosing cards in #{location}"
    end
    assert_not_empty possibilities
    kinds = choice.split(/,\s*/)
    if kinds.length == 1 && ctrl[:type] != :checkboxes
      params[key] = possibilities.index(kinds[0])
    else
      params[key] = kinds.map {|kind| possibilities.index(kind)}
    end
  end

  meth = ctrl[:action] || :resolve
  player.send(meth, params)

  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Provides the ability to choose none of my peeked or revealed cards
When(/^(\w*?)(?:'s)? chooses? none of (?:his|my) (revealed|peeked) cards$/) do |name, location|
  steps "When #{name} chooses his #{location} ,"
end

# Step for any control that requires you to make a choice of a card in play;
# that is, process any controls[:play] control
#
# Matches
#   I choose Estate in play
#   Bob chooses Estate, Copper in play
#   I choose Don't trash in play  // (Where "Don't trash" is the nil-action text)
When(/^(\w*?) chooses? (#{CardListNoCapture}|.*) in play$/) do |name, choices|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:play]
  flunk "No controls found in #{name}'s in-play" if controls.length == 0
  flunk "Unimplemented multi-in-play controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end

  if Array(ctrl[:nil_action]).include? choices
    params[:nil_action] = choices
  else
    possibilities = player.cards.in_play.map(&:readable_name)
    assert_not_empty possibilities

    kinds = choices.split(/,\s*/)
    if kinds.length == 1 && kinds[0] !~ /.* ?x ?\d*/
      params[key] = possibilities.index(kinds[0])
      assert_not_nil params[key], "Couldn't find #{kinds[0]} in play (#{possibilities.inspect})"
    else
      params[key] = []
      kinds.each do |kind|
        num = 1
        card_name = kind
        if /(.*) ?x ?(\d+)/ =~ kind
          card_name = $1.rstrip
          num = $2.to_i
        end

        num.times do
          ix = possibilities.index(card_name)
          possibilities[ix] = nil

          params[key] << ix
        end
      end
    end
  end

  player.resolve(params)

  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a single unattached choice; that is, process any button-type
# controls[:player] control
#
# Matches
#   I choose the option Don't discard
#   I choose the option Top of deck
When(/^(\w*?) chooses? the option (.*)/) do |name, choice|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:player]

  flunk "No controls found on player" if controls.length == 0
  # Look for an option of the chosen name anywhere in the controls
  found = false
  controls.each do |ctrl|
    params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
    params[:pa_id] = ctrl[:pa_id]

    matching_controls = ctrl[:options].detect {|opt| opt[:text] =~ /^#{Regexp.escape(choice)}$/i}
    if matching_controls
      params[:choice] = matching_controls[:choice]
      found = true
      player.resolve(params)
      break
    end
  end

  if !found
    flunk "Couldn't find #{choice} in #{controls.map {|c| c[:options].map {|o| o[:text]}}.inspect}"
  end

  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a single unattached choice for another player;
# that is, process any button-type controls[:other_players] control
#
# Matches
#   I choose for Bob the option Don't discard
#   I choose for Charlie the option Top of deck
When(/(.*) chooses? for (.*) the option (.*)/) do |name, target, choice|
  name = "Alan" if name == "I"
  target = "Alan" if target == "me"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:other_players]

  flunk "No controls found on player" if controls.length == 0
  # Look for an option of the chosen name anywhere in the controls
  controls.each do |ctrl|
    params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
    params[:pa_id] = ctrl[:pa_id]
    next unless params[:target] == @test_players[target].id.to_s

    matching_controls = ctrl[:options].detect do |opt|
      opt[:text] =~ /^#{Regexp.escape(choice)}$/i
    end
    if matching_controls
      params[:choice] = matching_controls[:choice]
      player.resolve(params)
      break
    end
  end

  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a checkboxed unattached choice; that is, process any
# checkbox-type controls[:player] control
#
# Matches
#   I choose the options Draw 1, +1 Action
When(/^(.*) chooses? the options (.*)$/) do |name, choices|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "Unimplemented multi-player controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  params[:choice] = choices.split(/,\s*/).map {|choice| ctrl[:choices].index(choice) }

  player.resolve(params)

  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for choosing from a dropdown control
#
# Matches:
#   I choose 0 from the dropdown
#   Bob chooses 2 from the dropdown
When /^(\w*?) chooses? (.*) from the dropdown/ do |name, choice|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "Unimplemented multi-dropdown controls in testbed" unless controls.length == 1
  flunk "Expected dropdown control" unless controls[0][:type] == :dropdown

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  params[:choice] = choice

  player.resolve(params)

  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to choose a pile; that is, process any controls[:piles] control
#
# Matches
#   I choose the Estate pile
#   Bob chooses the Estate, Copper piles
#   I choose Take nothing for piles  // (Where "Take nothing" is the nil-action text)
When(/^(\w*?) chooses? (?:the )?(.*?) (?:for )?piles?$/) do |name, choice|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-piles controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  if Array(ctrl[:nil_action]).include? choice
    params[:nil_action] = choice
  else
    possibilities = @test_game.piles.map{|p| p.card_class.readable_name}
    kinds = choice.split(/,\s*/)
    if kinds.length == 1
      if possibilities.index(kinds[0])
        params[:pile_index] = possibilities.index(kinds[0])
      else
        flunk "Chose a pile that doesn't exist"
      end
    else
      flunk "Can't think of any multiple-pile cards at the mo..."
    end
  end

  player.resolve(params)

  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to choose a pile; that is, process any controls[:piles] control
# Handles multiple controls present at once, by differentiating based on button text
#
# Matches
#   I choose the Estate pile
#   Bob chooses the Estate, Copper piles
#   I choose Take nothing for piles  // (Where "Take nothing" is the nil-action text)
When(/^(\w*?) chooses? (?:the )?(.*?) (?:for )?piles? labelled (.*)$/) do |name, choice, label|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  controls.select! {|c| c[:text] =~ /^#{Regexp.escape(label)}$/i}
  flunk "Unimplemented multi-piles controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  if Array(ctrl[:nil_action]).include? choice
    params[:nil_action] = choice
  else
    possibilities = @test_game.piles.map{|p| p.card_class.readable_name}
    kinds = choice.split(/,\s*/)
    if kinds.length == 1
      params[:pile_index] = possibilities.index(kinds[0])
    else
      flunk "Can't think of any multiple-pile cards at the mo..."
    end
  end

  player.resolve(params)

  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to choose an action on revealed cards
#
# Matches
#   I choose Discard for Bob's revealed Gold
#   Bob chooses Put back for my revealed Market
When(/^(\w*?) chooses? (.*?) for (\w*?)(?:'s)? revealed (#{SingleCardNoCapture}|nothing)/) do |name, choice, tgt_name, card|
  name = "Alan" if name == "I"
  player = @test_players[name]

  all_controls = player.determine_controls
  controls = all_controls[:revealed]

  tgt_name = "Alan" if tgt_name == "my"
  tgt_name = name if tgt_name == "his"
  target = @test_players[tgt_name]

  ctrl = controls.detect {|c| c[:player_id] == target.id}
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  params[:pa_id] = ctrl[:pa_id]

  if Array(ctrl[:nil_action]).include? choice
    params[:nil_action] = choice
  else
    card_ix = target.cards.revealed.map(&:readable_name).index(card)
    flunk "Can't find #{card} in #{tgt_name} revealed" unless card_ix
    if ctrl[:options]
      ix = ctrl[:options].index(choice)
      params[:choice] = "#{card_ix}.#{ix}"
    else
      params[:card_index] = card_ix;
    end
  end
  player.resolve(params)

  # Probably expect something to happen to the chosen card
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for Lookout. Nothing else. Well, anything that provides
# multiple options for each of a number of peeked cards on deck.
#
# Matches
#   I choose the matrix Trash the Estate, Discard the Province, Deck the Gold
When(/^(\w*?) chooses? the matrix ((?:\w+ the #{SingleCardNoCapture}(?:, )?)+)$/) do |name, choices|

  name = "Alan" if name == "I"
  player = @test_players[name]

  chosen_actions = choices.split(/,\s*/).map{|choice| choice.split(/ the /)}

  all_controls = player.determine_controls
  controls = all_controls[:peeked]
  flunk "No controls found in #{name}'s peeked deck cards" if controls.length == 0
  controls = controls[0]

  # Default values for the other params
  params = controls[:params]
  params[:pa_id] = controls[:pa_id]

  # Look at each peeked card (there may not necessarily be 3) and
  # assemble the corresponding action in params[:choice][n]
  peeked_cards = player.cards.peeked.map(&:readable_name)
  params[:choice] = []
  chosen_actions.each do |choice, cardname|
    # Determine card index in the peeked array
    card_ix = peeked_cards.index(cardname)
    assert_not_nil card_ix, "Couldn't find #{cardname} in peeked cards (#{peeked_cards.inspect})"

    # Determine value of this choice
    choice_val = controls[:options].find_index(choice)
    assert_not_nil card_ix, "Couldn't find option #{choice} in options (#{controls[:options].inspect})"

    # Store the appropriate choice in params[:choice]
    params[:choice] += [[card_ix.to_s, choice_val.to_s]]

    # Blank this card so that we can find a second one with the same name
    peeked_cards[card_ix] = nil
  end

  player.resolve(params)

  # Expect this to do something
  @skip_card_checking = 1 if @skip_card_checking == 0
end
