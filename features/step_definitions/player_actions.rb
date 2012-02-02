When /I gain (.*)/ do |kinds|
  kinds.split(/,\s+/).each do |kind|
    params = {}
    params[:pile] = @game.piles.where(:card_type => CARD_TYPES[kind].to_s)[0].id
    pa = @game.pending_actions.where(:parent_id => nil)[0]
    params[:parent_act] = pa.id
    @me.gain(params)
  end
  
  @game.process_actions
end