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

    "OK"
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

  resolves(:discard).validating_params_has(:card_index).
                      validating_param_is_card(:card_index, scope: :hand).
                      with do
    # All checks out. Discard the selected card.
    card = actor.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{actor.name} discarded #{card}.",
                           :css_class => "player#{actor.seat} card_discard")

    "OK"
  end
end