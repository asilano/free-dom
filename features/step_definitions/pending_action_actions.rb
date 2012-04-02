# Step for any control that requires you to make a choice in your hand; that is, process any controls[:hand] control
#
# Matches
#   I choose Estate in my hand
#   Bob chooses Estate, Copper in his hand
#   I choose Don't trash in my hand  // (Where "Don't trash" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (.*) in (?:his|my) hand/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params]
  key = if ctrl[:type] == :button
    :card_index
  else
    ctrl[:name].to_sym
  end
  
  if ctrl[:nil_action].andand == choice
    params[:nil_action] = true
  else
    possibilities = player.cards.hand.map(&:readable_name)
    kinds = choice.split(/,\s*/)
    if kinds.length == 1
      params[key] = possibilities.index(kinds[0])
    else
      params[key] = kinds.map {|kind| possibilities.index(kind)}
    end
  end
  
  player.resolve(params)
  
  # Probably chosen the card for a reason
  @skip_card_checking = 1
end

# Step for any control that requires you to make an unattached choice; that is, process any controls[:player] control
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
  params = ctrl[:params]
  
  params[:choice] = ctrl[:options].detect {|opt| opt[:text] =~ Regexp.new(choice, Regexp::IGNORECASE)}[:choice]
  
  player.resolve(params)
  
  # Probably chosen the option for a reason
  @skip_card_checking = 1
end

# Step for any control that requires you to choose a pile; that is, process any controls[:piles] control
#
# Matches
#   I choose the Estate pile
#   Bob chooses the Estate, Copper piles
#   I choose Don't buy for piles  // (Where "Don't trash" is the nil-action text)
When(/^(\w*?)(?:'s)? chooses? (?:the )?(.*) (?:for )?piles?/) do |name, choice|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We have to call resolve for the appropriate action with appropriate params.
  # So, really, we need to duplicate the logic of what to do with a control
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-piles controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  params = ctrl[:params]
  
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
  @skip_card_checking = 1
end