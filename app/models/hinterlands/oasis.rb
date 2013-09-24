class Hinterlands::Oasis < Card
  action
  costs 3
  card_text "Action (cost: 3) - Draw 1 card, +1 Action, +1 Cash. Discard a card."

  def play(parent_act)
    super

    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)
    player.add_cash(1)

    if player.cards.hand.empty?
      # Can't discard - just log
      game.histories.create!(:event => "#{player.name} had no cards in hand to discard.",
                            :css_class => "player#{player.seat} card_discard")
    elsif player.cards.hand.map(&:type).uniq.length == 1
      # All cards in hand are the same type - discard automatically
      return resolve_discard(player, {:card_index => '0'}, parent_act)
    else
      # There's an actual choice. Create a PendingAction to ask the question
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                  :text => "Discard a card with #{self}",
                                  :game => game,
                                  :player => player)
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Discard",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                         }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include?(:card_index)
      return "Invalid parameters"
    end

    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to discard an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Discard the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{ply.name} discarded #{card}.",
                           :css_class => "player#{ply.seat} card_discard")

    return "OK"
  end
end