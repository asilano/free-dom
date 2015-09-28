class Intrigue::WishingWell < Card
  costs 3
  action
  card_text "Action(cost: 3) - Draw 1 card, +1 Action. Name a card, then reveal the top card of " +
            "your deck. If it's the named card, put it into your hand."

  def play(parent_act)
    super

    # Draw and gain an action. We need the new action to hang the next step off
    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)

    # Create the PendingAction to "name" a card.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_name",
                               :text => "Name a card, with Wishing Well",
                               :player => player,
                               :game => game)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "name"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Name this",
                            :nil_action => "Name '#{Card.non_card}'",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "name"},
                            :piles => [true] * game.piles.size
                          }]
    end
  end

  def resolve_name(ply, params, parent_act)
    # We expect to have been passed a :pile_index or :nil_action
    if not params.include? :pile_index and not params.include? :nil_action
      return "Invalid parameters"
    end

    # Check that the pile is in range
    if ((params.include? :pile_index) and
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to name an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    end

    if params.include? :nil_action
      # Player named a nonsense card.
      game.histories.create!(:event => "#{ply.name} named #{params[:nil_action].match(/Name '(.*)'/)[1]}.",
                            :css_class => "player#{ply.seat}")
    else
      # Player has named a card. Write the name to history
      pile = game.piles[params[:pile_index].to_i]
      game.histories.create!(:event => "#{ply.name} named '#{pile.card_type.readable_name}'.",
                            :css_class => "player#{ply.seat}")
    end

    # Now  "reveal" the top card of the deck - actually, just write it to
    # history - after making sure the deck has a card in it.
    if ply.cards(true).deck.length == 0
      ply.shuffle_discard_under_deck
    end

    if ply.cards.deck.length == 0
      # Still no cards in deck, so Wishing Well fizzles
      game.histories.create!(:event => "#{ply.name} couldn't reveal a card to Wishing Well - no cards in deck.",
                            :css_class => "player#{ply.seat}")
    else
      # Write the top card to history
      card = ply.cards.deck[0]
      game.histories.create!(:event => "#{ply.name} revealed a #{card.readable_name} to the Wishing Well.",
                            :css_class => "player#{ply.seat} card_reveal")

      if !params.include?(:nil_action) && card.class == pile.card_class
        # Named card matches the top card - put it into the player's hand.
        # Note that this is not a "draw" - which is irrelevant at the moment,
        # but you can never be too careful.
        game.histories.create!(:event => "Named card matches top of deck - #{ply.name} puts the card into their hand.",
                            :css_class => "player#{ply.seat}")
        if ply.cards.hand.empty?
          card.position = 0
        else
          card.position = ply.cards.hand[-1].position + 1
        end
        ply.cards.hand << card
        card.location = "hand"
        card.save!
      end
    end

    return "OK"
  end
end