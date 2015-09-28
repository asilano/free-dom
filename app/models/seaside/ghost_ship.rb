# 21  Ghost Ship  Seaside  Action - Attack  $5  +2 Card, Each other player with 4 or more cards in hand puts cards from his hand on top of his deck until he has 3 cards in his hand.

class Seaside::GhostShip < Card
  costs 5
  action :attack => true
  card_text "Action (Attack; cost: 5) - Draw 2 cards. Each other player with 4 or more cards in hand puts cards from his hand on top of his deck until he has 3 cards in his hand."

  def play(parent_act)
    super

    # This is pretty similar to militia really, except the cards go on top of deck instead of getting discarded.

    # +2 cards
    player.draw_cards(2)

    # Now, attack
    attack(parent_act)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "place"
      # This is the target choosing one card to discard
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Place",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "place"},
                           :cards => [true] * player.cards.hand.size
                          }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to place
    # enough cards to reduce their hand to 3.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Determine how many cards to place - never negative
    num_places = [0, target.cards(true).hand.size - 3].max

    # Hang that many actions off the parent to ask the target to place a card
    1.upto(num_places) do |num|
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place",
                                              :text => "Place #{num} card#{num > 1 ? 's' : ''} on top of deck")
      parent_act.player = target
      parent_act.game = game
      parent_act.save!
    end

    return "OK"
  end

  def resolve_place(ply, params, parent_act)
    # This is processing the target's request to place a card
    # We expect to have been passed a :card_index
    if not params.include? :card_index
      return "Invalid parameters"
    end

    if ((params.include? :card_index) and
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to place an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Place the selected card.
    # :card_index specified. Place the specified card on top of the player's
    # deck, and "reveal" it by creating a history.
    card = ply.cards.hand[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.save!
    ply.renum(:deck)
    game.histories.create!(:event => "#{ply.name} put a [#{ply.id}?#{card.class.readable_name}|card] on top of their deck.",
                          :css_class => "player#{ply.seat}")

    return "OK"
  end
end
