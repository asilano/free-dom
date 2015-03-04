class BaseGame::Militia < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - +2 cash. Each other player discards down " +
                                        "to 3 cards."

  def play(parent_act)
    super

    # Grant the player 2 cash
    player.add_cash(2)

    # Then conduct the attack
    attack(parent_act)

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "discard"
      # This is the target choosing one card to discard
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

  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to discard
    # enough cards to reduce their hand to 3.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Determine how many cards to discard - never negative
    num_discards = [0, target.cards.hand(true).size - 3].max

    # Hang that many actions off the parent to ask the target to discard a card
    1.upto(num_discards) do |num|
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                              :text => "Discard #{num} card#{num > 1 ? 's' : ''}")
      parent_act.player = target
      parent_act.game = game
      parent_act.save!
    end

    "OK"
  end

  resolves(:discard).validating_params_has(:card_index).
                     validating_param_is_card(:card_index, scope: :hand).
                     with do
    # All checks out. Discard the selected card.
    card = actor.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{actor.name} discarded #{card.class.readable_name}.",
                            :css_class => "player#{actor.seat} card_discard")

    "OK"
  end
end
