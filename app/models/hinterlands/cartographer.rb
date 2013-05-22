# "You do open heart surgery? In here?"
# "Uh, no. I'm the mapmaking sort of cartographer."
class Hinterlands::Cartographer < Card
  action
  costs 5
  card_text "Action (cost: 5) - Draw 1 card, +1 Action. Look at the top 4 cards of your deck. " +
            "Discard any number of them. Put the rest back on top in any order."

  def play(parent_act)
    super

    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)

    # Peek at the top 4 cards of the deck
    num_seen = player.peek_at_deck(4, :top).length

    if (num_seen != 0)
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                  :text => "Discard any number of cards with #{self}",
                                  :player => player,
                                  :game => game)
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:peeked] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]
    when "place"
      controls[:peeked] += [{:player_id => player.id,
                            :type => :button,
                            :action => :resolve,
                            :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "place",
                                        :posn => params[:posn]},
                            :cards => [true] * player.cards.peeked.length
                           }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # The player can choose to discard nothing; if a :discard paramter is
    # present, we expect each entry to be a valid card index.
    if (params.include?(:discard) &&
        params[:discard].any? {|d| d.to_i < 0 or d.to_i >= ply.cards.peeked.size})
      return "Invalid parameters - at least one card index out of range"
    end

    # Looks good.
    if !params.include?(:discard)
      # No discarding to do; create a log
      game.histories.create!(:event => "#{ply.name} discarded no cards to #{self}.",
                             :css_class => "player#{ply.seat} card_discard")
    else
      # Discard each selected card, taking note of its class for logging purposes
      cards_discarded = []
      cards_chosen = params[:discard].map {|ix| ply.cards.peeked[ix.to_i]}
      cards_chosen.each do |card|
        card.discard
        cards_discarded << card.class.readable_name
      end

      # Log the discards
      game.histories.create!(:event => "#{ply.name} discarded #{cards_discarded.join(', ')} with #{self}.",
                             :css_class => "player#{ply.seat} card_discard")
    end

    remain = ply.cards.peeked(true).count
    if remain == 0
      # Nothing to put back
    elsif remain == 1
      # One card to put back. Actually, just unpeek it and log
      card = ply.cards.peeked[0]
      card.peeked = false
      card.save!

      game.histories.create!(:event => "#{ply.name} put [#{ply.id}?#{card}|a card] back on their deck.",
                             :css_class => "player#{ply.seat}")
    else
      # More than one card. Create pending actions to put the remaining cards back in any
      # order. We don't need an action for the last one.
      (2..ply.cards.peeked.length).each do |ix|
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=#{ix}",
                                                 :text => "Put a card #{ActiveSupport::Inflector.ordinalize(ix)} from top with #{self}",
                                                 :player => ply,
                                                 :game => game)
      end
    end

    return "OK"
  end

  def resolve_place(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end

    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.peeked.length - 1))
      # Asked to place an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Place the selected card on top of the deck (position -1),
    # unpeek it, and renumber.
    card = ply.cards.peeked[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.peeked = false
    card.save!
    game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                          :css_class => "player#{ply.seat}")

    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless ply.cards.peeked(true).count == 1
      card = ply.cards.peeked[0]
      card.location = "deck"
      card.position = -2
      card.peeked = false
      card.save!
      game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] on top of their deck.",
                             :css_class => "player#{ply.seat}")
    end

    return "OK"
  end
end