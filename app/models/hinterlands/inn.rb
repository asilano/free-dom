class Hinterlands::Inn < Card
  action
  costs 5
  card_text "Action (costs: 5) - Draw 2 cards, +2 Actions. Discard 2 cards. / When you gain this, " +
            "look through your discard pile (including this), reveal any number of Action cards " +
            "from it, and shuffle them into your deck."

  def play(parent_act)
    super

    # First, draw the cards.
    player.draw_cards(2)

    # Now create the new Actions
    parent_act = player.add_actions(2, parent_act)

    # If the player has very few cards in deck, it's possible for the draw to fail, and
    # thus there to be fewer than 3 cards available to discard.
    num_discards = [2, player.cards.hand.length].min

    if (0 == num_discards)
      # Just log that we're out of cards
      game.histories.create!(:event => "#{player.name} discarded no cards to #{self}, due to having none.",
                             :css_class => "player#{player.seat} card_discard")
    elsif (num_discards == player.cards.hand.length)
      # Only got as many cards as we need to discard, so discard them all.
      player.cards.hand.each do |card|
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                               :css_class => "player#{player.seat} card_discard")
      end
    elsif (player.cards.hand.map(&:class).uniq.length == 1)
      # Only one type of card in hand, so discard without question
      (1..num_discards).each do |ix|
        card = player.cards.hand[-ix]
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                              :css_class => "player#{player.seat} card_discard")
      end
    else
      # Queue up the requests to do the discards
      1.upto(num_discards) do |num|
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                                :text => "Discard #{num} card#{num > 1 ? 's' : ''}",
                                                :player => player,
                                                :game => game)
      end
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
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

    when "return"
      controls[:peeked] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "return",
                           :choice_text => "Choose",
                           :button_text => "Shuffle selected cards in",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "return"},
                           :cards => [true] * player.cards.peeked.length
                          }]
    end
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

  # Notice a Gain after it's happened. If the card being gained is Inn itself, queue up to ask which actions to return.
  # We must ensure the gain happens first; the card text is quite explicit about that.
  def self.witness_post_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Inn, and if so queue an action to trigger asking for what
    # to return.
    if card.class == self
      parent_act.children.create!(:expected_action => "resolve_#{self}#{card.id}_query",
                                  :game => game)
    end

    # The gain of Inn must not be affected, so we can choose to return it.
    return false
  end

  def query(params)
    parent_act = params[:parent_act]

    # Find action cards in discard
    acts_in_discard = player.cards.in_discard.select(&:is_action?)

    unless acts_in_discard.empty?
      # Peek at each such card, then add an action
      acts_in_discard.each(&:peek)
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_return",
                                  :text => "Shuffle discarded actions into deck",
                                  :player => player,
                                  :game => game)
    else
      # No actions in discard. This is, actually, possible; due to Watchtower or Royal Seal.
      # Call resolve directly to log.
      resolve_return(player, {}, parent_act)
    end
  end

  # The player can choose to return nothing; if a :return paramter is
  # present, we expect each entry to be a valid card index.
  resolves(:return).validating_param_is_card_array(:return, scope: :peeked).with do
    # Looks good.
    if !params.include?(:return)
      # No returning to do; create a log
      game.histories.create!(:event => "#{actor.name} returned no cards with #{self}.",
                             :css_class => "player#{actor.seat}")
    else
      # Place each selected card on the deck, taking note of its class for logging purposes
      cards_returned = []
      cards_chosen = params[:return].map {|ix| actor.cards.peeked[ix.to_i]}
      cards_chosen.each do |card|
        card.location = "deck"
        card.save!
        cards_returned << card.readable_name
      end

      # Log the returns
      game.histories.create!(:event => "#{actor.name} returned #{cards_returned.join(', ')} to their deck with #{self}.",
                             :css_class => "player#{actor.seat}")
    end

    # Even if no cards were returned, shuffle the deck
    actor.cards.deck.shuffle.each.with_index do |card, index|
      card.position = index
      card.save!
    end

    "OK"
  end
end