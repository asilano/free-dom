# Matches
#   I gain Copper
#   Bob gains Copper, Silver
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
