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

    return "OK"
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

    return "OK"
  end

  def resolve_discard(ply, params, parent_act)
    # This is processing the target's request to discard a card
    # We expect to have been passed a :card_index
    if not params.include? :card_index
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
    game.histories.create!(:event => "#{ply.name} discarded #{card.class.readable_name}.",
                            :css_class => "player#{ply.seat} card_discard")

    return "OK"
  end
end
