class Hinterlands::Stables < Card
  action
  costs 5
  card_text "Action (costs: 5) - You may discard a Treasure. If you do, draw 3 cards and +1 Action."

  def play(parent_act)
    super

    if player.cards.hand.any?(&:is_treasure?)
      # Create an action to poll for the discard
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                  :text => "Discard a Treasure with #{self}",
                                  :player => player,
                                  :game => game)
    else
      # No treasures in hand. Call resolve directly
      resolve_discard(player, {:nil_action => true}, parent_act)
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      # This is the player choosing a treasure card to discard
      controls[:hand] += [{:type => :button,
                           :text => "Discard",
                           :nil_action => "Don't discard",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => player.cards.hand.map(&:is_treasure?)
                          }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # Player has made a choice of what card to discard.
    # We expect to have been passed a :card_index
    if !params.include?(:card_index) && !params.include?(:nil_action)
      return "Invalid parameters"
    end

    if params.include? :card_index
      # Processing is pretty much the same as a Play; code shamelessly yoinked from
      # Player.play_action.
      if ((params[:card_index].to_i < 0 ||
           params[:card_index].to_i > ply.cards.hand.length - 1))
        # Asked to play an invalid card (out of range)
        return "Invalid request - card index #{params[:card_index]} is out of range"
      elsif !ply.cards.hand[params[:card_index].to_i].is_treasure?
        # Asked to play an invalid card (not an reaction)
        return "Invalid request - card index #{params[:card_index]} is not a treasure"
      end

      # All checks out. Discard the card, then draw 3 and grant an action
      card = ply.cards.hand[params[:card_index].to_i]
      card.discard

      game.histories.create!(:event => "#{ply.name} discarded #{card} to #{self}",
                             :css_class => "player#{ply.seat} card_discard")

      ply.draw_cards(3)
      ply.add_actions(1, parent_act)
    else
      # Player chose not to discard. Just log
      game.histories.create!(:event => "#{ply.name} discarded nothing to #{self}",
                             :css_class => "player#{ply.seat}")

    end

    return "OK"
  end

end