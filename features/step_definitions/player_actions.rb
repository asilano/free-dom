When(/(.*) gain(?:s)? (.*)/) do |name, kinds|
  name = "Alan" if name == "I"
  
  kinds.split(/,\s+/).each do |kind|
    params = {}
    params[:pile] = @game.piles.where(:card_type => CARD_TYPES[kind].to_s)[0].id
    pa = @game.pending_actions.where(:parent_id => nil)[0]
    params[:parent_act] = pa.id
    @players[name].gain(params)
  end
  
  @game.process_actions
  
  # Need the test to tell us what card movements are expected; especially since Watchtower etc can step in.
  @skip_card_checking = 1
end

When(/(.*) choose(?:s)? ((?:(?:#{CARD_NAMES.join('|')})(?:, )?)*) in (?:his|my) hand/) do |name, kinds|
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
  
  possibilities = player.cards.hand.map(&:readable_name)
  kinds_a = kinds.split(/,\s*/)
  if kinds_a.length == 1
    params[key] = possibilities.index(kinds_a[0])
  else
    params[key] = kinds_a.map {|kind| possibilities.index(kind)}
  end
  
  player.resolve(params)
  
  # Probably chosen the card for a reason
  @skip_card_checking = 1
end