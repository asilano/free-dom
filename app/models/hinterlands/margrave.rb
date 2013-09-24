class Hinterlands::Margrave < Card
  action :attack => true
  costs 5
  card_text "Action (Attack; costs: 5) - Draw 3 cards, +1 Buy. " +
            "Each other player draws a card, then discards down to 3 cards in hand."

  def play(parent_act)
    super

    player.draw_cards(3)
    player.add_buys(1, parent_act)

    # Trigger the attack!
    attack(parent_act)

    "OK"
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, the target draws a card, then ask the target to discard
    # enough cards to reduce their hand to 3.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    target.draw_cards(1)

    # Determine how many cards to discard - never negative
    num_discards = [0, target.cards.hand(true).size - 3].max

    if (target.cards.hand.map(&:class).uniq.length == 1)
      # Only one type of card in hand. Discard enough of those.
      num_discards.downto(1) do |ix|
        resolve_discard(target, {:card_index => ix}, parent_act)
      end
    else
      # Hang that many actions off the parent to ask the target to discard a card
      1.upto(num_discards) do |num|
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                                :text => "Discard #{num} card#{num > 1 ? 's' : ''} to #{self}",
                                                :player => target,
                                                :game => game)
      end
    end
    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "discard"
      # This is the target choosing one card to discard
      controls[:hand] += [{:type => :button,
                           :text => "Discard",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # This is processing the target's request to discard a card
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end

    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to discard an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Discard the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{ply.name} discarded #{card} to #{self}.",
                            :css_class => "player#{ply.seat} card_discard")

    return "OK"
  end

end