# Rabble (Action - Attack - $5) - Draw 3 Cards. Each other player reveals the top 3 cards of his deck, discards the revealed Actions and Treasures, and puts the rest back on top in any order.

class Prosperity::Rabble < Card
  action :attack => true
  costs 5
  card_text "Action (Attack; cost: 5) - Draw 3 cards. Each other player reveals the top 3 cards of his deck, discards the revealed Actions and Treasures, and puts the rest back on top in any order."

  def play(parent_act)
    super

    player.draw_cards(3)

    attack(parent_act)
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "place"
      controls[:revealed] += [{:player_id => player.id,
                               :type => :button,
                               :action => :resolve,
                               :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "place",
                                           :posn => params[:posn]},
                               :cards => [true] * player.cards.revealed.length
                              }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, discard any Actions and Treasures in the target's
    # top three deck cards, then reveal the rest and ask to put them back.
    target = Player.find(params[:target])
    parent_act = params[:parent_act]

    # Ensure they have 3 cards to reveal, if possible
    shuffle_point = target.cards.deck.count
    if target.cards(true).deck.count < 3
      target.shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    if target.cards.deck.count == 0
      # No cards
      game.histories.create!(:event => "#{target.name} had no cards in deck.",
                            :css_class => "player#{target.seat}")
    else
      discarded_cards = []
      revealed_cards = []

      # Look through the top three cards, or however many there are if fewer.
      target.cards.deck[0, 3].each do |card|
        revealed_cards << card
        if card.is_action? || card.is_treasure?
          # Discard this card
          discarded_cards << card
          card.discard
        end
      end

      for_log = revealed_cards.dup

      # Log the cards revealed and discarded
      if shuffle_point > 0 && shuffle_point < revealed_cards.length
        for_log.insert(shuffle_point, "(#{target.name} shuffled their discards)")
      end
      game.histories.create!(:event => "#{target.name} revealed #{for_log.join(', ')}.",
                           :css_class => "player#{target.seat} card_reveal #{'shuffle' if (shuffle_point > 0 && shuffle_point < revealed_cards.length)}")
      game.histories.create!(:event => "#{target.name} discarded #{discarded_cards.join(', ')}.",
                            :css_class => "player#{target.seat} card_discard") unless discarded_cards.empty?

      if revealed_cards.length < 3
        # Couldn't do all three. Log it.
        game.histories.create!(:event => "#{target.name} tried to reveal #{3 - revealed_cards.length} more card#{'s' unless revealed_cards.length == 2}, but their deck was empty.",
                              :css_class => "player#{target.seat}")
      end

      # If there were 2 or more cards revealed but not discarded, reveal them properly and ask for them to be put back.
      remaining_types = revealed_cards.reject { |c| c.is_treasure? || c.is_action? }.map(&:class)
      if (revealed_cards.length >= discarded_cards.length + 2) && remaining_types.uniq.length > 1
        target.renum(:deck)
        target.reveal_from_deck(revealed_cards.length - discarded_cards.length, :silent => true)
        (2..target.cards.revealed.length).each do |ix|
          parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=#{ix}",
                                                  :text => "Put a card #{ActiveSupport::Inflector.ordinalize(ix)} from top",
                                                  :player => target,
                                                  :game => game)
        end
      elsif revealed_cards.length >= discarded_cards.length + 2
        # All cards must be the same type. Log that they're being put back
        game.histories.create!(:event => "#{target.name} replaced their revealed cards on their deck.",
                               :css_class => "player#{target.seat}")
      end
    end

    return "OK"
  end

  def resolve_place(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if not params.include? :card_index
      return "Invalid parameters"
    end

    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.revealed.count - 1))
      # Asked to place an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Place the selected card on top of the deck (position -1),
    # unpeek it, and renumber.
    card = ply.cards.revealed[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.revealed = false
    card.save!
    game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                          :css_class => "player#{ply.seat}")

    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless ply.cards(true).revealed.count == 1
      card = ply.cards.revealed[0]
      card.location = "deck"
      card.position = -2
      card.revealed = false
      card.save!
      game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card}|a card] on top of their deck.",
                            :css_class => "player#{ply.seat}")
    end

    ply.renum(:deck)

    # Now, if the revealed cards are all of the same type, we can put them back as well
    if ply.cards.revealed.map(&:class).uniq.length == 1
      resolve_place(ply, {card_index: 0, posn: params[:posn].to_i - 1}, parent_act)
      ply.pending_actions.where('expected_action LIKE ?', "resolve_#{self.class}#{id}_place;posn=%").destroy_all
    end

    return "OK"
  end
end