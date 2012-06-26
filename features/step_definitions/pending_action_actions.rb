# Step for any control that requires you to make a choice in your hand; that is, process any controls[:hand] control
#
# Matches
#   I choose Estate in my hand
#   Bob chooses Estate, Copper in his hand
#   I choose Don't trash in my hand  // (Where "Don't trash" is the nil-action text)
When(/^(\w*?) chooses? (.*) in (?:his|my) hand/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}

  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end
  
  if ctrl[:nil_action].andand == choice
    params[:nil_action] = true
  else
    possibilities = player.cards.hand.map(&:readable_name)
    assert_not_empty possibilities
    kinds = choice.split(/,\s*/)
    if kinds.length == 1
      params[key] = possibilities.index(kinds[0])
    else
      params[key] = kinds.map {|kind| possibilities.index(kind)}
    end
  end
  
  player.resolve(params)
  
  # Probably chosen the card for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a choice of revealed cards; that is, process any controls[:revealed] control
#
# Matches
#   I choose my revealed Estate in my hand
#   Bob chooses his revealed Estate, Copper
#   I choose my revealed Don't trash // (Where "Don't trash" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (?:his|my) revealed (.*)/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:revealed]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}

  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end
  
  if ctrl[:nil_action].andand == choice
    params[:nil_action] = true
  else
    possibilities = player.cards.revealed.map(&:readable_name)
    assert_not_empty possibilities
    kinds = choice.split(/,\s*/)
    if kinds.length == 1
      params[key] = possibilities.index(kinds[0])
    else
      params[key] = kinds.map {|kind| possibilities.index(kind)}
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
When(/(.*) chooses? the option (.*)/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "Unimplemented multi-player controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  
  params[:choice] = ctrl[:options].detect {|opt| opt[:text] =~ Regexp.new(Regexp.escape(choice), Regexp::IGNORECASE)}[:choice]
  
  player.resolve(params)
  
  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to make a checkboxed unattached choice; that is, process any 
# checkbox-type controls[:player] control
#
# Matches
#   I choose the options Draw 1, +1 Action
When(/(.*) chooses? the options (.*)/) do |name, choices|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "Unimplemented multi-player controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}

  params[:choice] = choices.split(/,\s*/).map {|choice| ctrl[:choices].index(choice) }
  
  player.resolve(params)
  
  # Probably chosen the option for a reason
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Step for any control that requires you to choose a pile; that is, process any controls[:piles] control
#
# Matches
#   I choose the Estate pile
#   Bob chooses the Estate, Copper piles
#   I choose Don't buy for piles  // (Where "Don't buy" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (?:the )?(.*?) (?:for )?piles?$/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-piles controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  
  if ctrl[:nil_action].andand == choice
    params[:nil_action] = true
  else
    possibilities = @game.piles.map{|p| p.card_type.readable_name}
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

# Step for any control that requires you to choose a pile; that is, process any controls[:piles] control
# Handles multiple controls present at once, by differentiating based on button text
#
# Matches
#   I choose the Estate pile
#   Bob chooses the Estate, Copper piles
#   I choose Don't buy for piles  // (Where "Don't buy" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (?:the )?(.*?) (?:for )?piles? labelled (.*)$/) do |name, choice, label|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  controls.select! {|c| c[:text] =~ Regexp.new(Regexp.escape(label), Regexp::IGNORECASE)}
  flunk "Unimplemented multi-piles controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  
  if ctrl[:nil_action].andand == choice
    params[:nil_action] = true
  else
    possibilities = @game.piles.map{|p| p.card_type.readable_name}
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
  player = @players[name]

  all_controls = player.determine_controls
  controls = all_controls[:revealed] 
  
  tgt_name = "Alan" if tgt_name == "my"
  target = @players[tgt_name]

  ctrl = controls.detect {|c| c[:player_id] == target.id}
  params = ctrl[:params].inject({}) {|h,kv| h[kv[0]] = kv[1].to_s; h}
  
  if ctrl[:nil_action].andand == choice
    params[:choice] = "nil_action"
  elsif (ix = ctrl[:options].index(choice))
    card_ix = target.cards.revealed.map(&:readable_name).index(card)
    flunk "Can't find #{card} in #{tgt_name} revealed" unless card_ix

    params[:choice] = "#{card_ix}.#{ix}"
  end
  Rails.logger.info(params.inspect)
  player.resolve(params)

  # Probably expect something to happen to the chosen card
  @skip_card_checking = 1 if @skip_card_checking == 0
end

    
