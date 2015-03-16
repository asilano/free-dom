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

  resolves(:discard).validating_params_has_any_of(:card_index, :nil_action).
                      validating_param_is_card(:card_index, scope: :hand, &:is_treasure?).
                      with do
    if params.include? :card_index
      # Discard the card, then draw 3 and grant an action
      card = actor.cards.hand[params[:card_index].to_i]
      card.discard

      game.histories.create!(:event => "#{actor.name} discarded #{card} to #{self}",
                             :css_class => "player#{actor.seat} card_discard")

      actor.draw_cards(3)
      actor.add_actions(1, parent_act)
    else
      # Player chose not to discard. Just log
      game.histories.create!(:event => "#{actor.name} discarded nothing to #{self}",
                             :css_class => "player#{actor.seat}")

    end

    "OK"
  end
end
