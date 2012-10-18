class Intrigue::Baron < Card
  costs 4
  action
  card_text "Action (cost: 4) - +1 Buy. You may discard an Estate card. If you do, +4 cash; otherwise, gain an Estate."

  def play(parent_act)
    super

    # First, add the buy.
    player.add_buys(1, parent_act)

    if player.cards.hand.of_type("BasicCards::Estate").empty?
      # No Estate in hand; call resolve_discard with nil_action
      return resolve_discard(player, {:nil_action => true}, parent_act)
    else
      # Check for AutoBaroning
      if player.settings.autobaron
        # AutoBaron is on. Call resolve_discard directly, to avoid code duplication
        ix = player.cards.hand.index {|c| c.class == BasicCards::Estate}
        return resolve_discard(player, {:card_index => ix}, parent_act)
      else
        # Now, ask to discard an Estate card.
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                   :text => "Discard an Estate, or decline to",
                                   :player => player,
                                   :game => game)
      end
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Discard",
                           :nil_action => "Take Estate",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => player.cards.hand.map do |card|
                             card.class == BasicCards::Estate
                           end
                          }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to discard an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif ((params.include? :card_index) and
           (ply.cards.hand[params[:card_index].to_i][:type] !~ /Estate/))
      # Asked to discard a non-estate
      return "Invalid request - card index #{params[:card_index]} is not an Estate"
    end

    # All checks out. Carry on
    if params.include? :nil_action
      # No discard; take an estate
      game.histories.create!(:event => "#{ply.name} discarded nothing, and gained an Estate.",
                            :css_class => "player#{ply.seat} card_gain")
      estate_pile = game.piles.find_by_card_type("BasicCards::Estate")

      ply.gain(parent_act, estate_pile.id)
    else
      # Discard the selected card, and grant 4 cash.
      card = ply.cards.hand[params[:card_index].to_i]
      card.discard
      game.histories.create!(:event => "#{ply.name} discarded an Estate.",
                            :css_class => "player#{ply.seat} card_discard")

      ply.add_cash(4)
    end

    return "OK"
  end
end