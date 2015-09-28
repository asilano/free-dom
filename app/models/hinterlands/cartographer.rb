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
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.peeked.length
                          }]
    when "place"
      controls[:peeked] += [{:type => :button,
                            :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "place",
                                        :posn => params[:posn]},
                            :cards => [true] * player.cards.peeked.length
                           }]
    end
  end

  # The player can choose to discard nothing, resulting in no parameters.
  # If a :discard paramter is present, we expect each entry to be a valid card index.
  resolves(:discard).validating_param_is_card_array(:discard, scope: :peeked).
                      with do
    if !params.include?(:discard)
      # No discarding to do; create a log
      game.histories.create!(:event => "#{actor.name} discarded no cards to #{self}.",
                             :css_class => "player#{actor.seat} card_discard")
    else
      # Discard each selected card, taking note of its class for logging purposes
      cards_discarded = []
      cards_chosen = params[:discard].map {|ix| actor.cards.peeked[ix.to_i]}
      cards_chosen.each do |card|
        card.discard
        cards_discarded << card.class.readable_name
      end

      # Log the discards
      game.histories.create!(:event => "#{actor.name} discarded #{cards_discarded.join(', ')} with #{self}.",
                             :css_class => "player#{actor.seat} card_discard")
    end

    remain = actor.cards(true).peeked.count
    if remain == 0
      # Nothing to put back
    elsif remain == 1
      # One card to put back. Actually, just unpeek it and log
      card = actor.cards.peeked[0]
      card.peeked = false
      card.save!

      game.histories.create!(:event => "#{actor.name} put [#{actor.id}?#{card}|a card] back on their deck.",
                             :css_class => "player#{actor.seat}")
    else
      # More than one card. Create pending actions to put the remaining cards back in any
      # order. We don't need an action for the last one.
      act = parent_act
      (2..actor.cards.peeked.length).each do |ix|
        act = act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=#{ix}",
                                   :text => "Put a card #{ActiveSupport::Inflector.ordinalize(ix)} from top with #{self}",
                                   :player => actor,
                                   :game => game)
      end
    end

    "OK"
  end

  resolves(:place).validating_params_has(:card_index).
                    validating_param_is_card(:card_index, scope: :peeked).
                    validating_params_has(:posn).
                    validating_param_satisfies(:posn) { |value, context| value.to_i == context.actor.cards.peeked.count }.
                    with do
    # Place the selected card on top of the deck (position -1),
    # unpeek it, and renumber.
    card = actor.cards.peeked[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.peeked = false
    card.save!
    game.histories.create!(:event => "#{actor.name} placed [#{actor.id}?#{card.class.readable_name}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                          :css_class => "player#{actor.seat}")

    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless actor.cards(true).peeked.count == 1
      card = actor.cards.peeked[0]
      card.location = "deck"
      card.position = -2
      card.peeked = false
      card.save!
      game.histories.create!(:event => "#{actor.name} placed [#{actor.id}?#{card.class.readable_name}|a card] on top of their deck.",
                             :css_class => "player#{actor.seat}")
    end

    "OK"
  end
end