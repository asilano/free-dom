class Hinterlands::Mandarin < Card
  action
  costs 5
  card_text "Action (costs: 5) - +3 Cash. Put a card from your hand on top of your deck. / " +
            "When you gain this, put all Treasures you have in play on top of your deck in any order."

  def play(parent_act)
    super

    player.add_cash(3)

    # Queue up the action to put a card on deck.
    if player.cards.hand.empty?
      # Nothing to replace. Just log
      game.histories.create!(:event => "#{player.name} couldn't put a card on their deck " +
                                       "with #{self}, as they had none in hand.",
                             :css_class => "player#{player.seat}")
    elsif player.cards.hand.map(&:class).uniq.length == 1
      # All cards in hand are the same. Call resolve directly
      resolve_place(player, {:card_index => 0}, parent_act)
    else
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place",
                                  :text => "Put a card from hand onto deck",
                                  :player => player,
                                  :game => game)
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "place"
      # Putting a card from hand to deck, as part of playing Mandarin
      controls[:hand] += [{:type => :button,
                           :text => "Place",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "place"},
                           :cards => [true] * player.cards.hand.size
                          }]
    when "return"
      controls[:play] += [{:type => :button,
                           :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                           :nil_action => "Any order",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "return",
                                       :posn => params[:posn]},
                           :cards => player.cards.in_play.map(&:is_treasure?)
                          }]
    end
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
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to place an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Place the selected card on the deck.
    card = ply.cards.hand[params[:card_index].to_i]
    player.renum(:deck)
    card.location = 'deck'
    card.position = -1
    card.save!
    game.histories.create!(:event => "#{ply.name} put [#{ply.id}?#{card.class.readable_name}|a card] " +
                                     "from their hand onto their deck.",
                            :css_class => "player#{ply.seat}")

    return "OK"
  end

  # Notice a gain event. If it's Mandarin itself, queue up some actions to return treasures
  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Mandarin, and if so queue to return treasures
    if card.class == self
      treasures = ply.cards.in_play.select(&:is_treasure?)
      if treasures.empty?
        # No treasures in play - just log.
        game.histories.create!(:event => "#{ply.name} had no treasures in play to return with #{self}.",
                               :css_class => "player#{ply.seat}")
      elsif treasures.map(&:class).uniq.length == 1
        # Only one type of treasure in play, so order doesn't matter. Which means we might as well call resolve, stating
        # Order doesn't matter.
        card.resolve_return(ply, {:nil_action => true}, parent_act)
      else
        2.upto(treasures.length) do |ix|
          parent_act = parent_act.children.create!(:expected_action => "resolve_#{self}#{card.id}_return;posn=#{ix}",
                                                   :text => "Put a treasure #{ActiveSupport::Inflector.ordinalize(ix)} from top with #{readable_name}",
                                                   :player => ply,
                                                   :game => game)
        end
      end
    end

    # Mandarin's trigger doesn't affect gain of the Mandarin itself
    return false
  end

  def resolve_return(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if !params.include?(:nil_action) && !params.include?(:card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.in_play.length - 1))
      # Asked to return an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    if params.include? :nil_action
      # Returning the remaining cards in any order. Y'know what? Let's just call ourselves to do it.
      ply.cards.in_play.select(&:is_treasure?).length.downto(2) do |posn|
        ix = ply.cards.in_play(true).index(&:is_treasure?)
        resolve_return(ply, {:card_index => ix, :posn => posn}, parent_act)
      end

      # Remove all pending actions above this that are for replacing with Mandarin
      ply.pending_actions.where('expected_action LIKE ?', "resolve_#{self.class}#{id}_return;posn=%").destroy_all
      return "OK"
    end

    card = ply.cards.in_play[params[:card_index].to_i]
    if !card.is_treasure?
      # Asked to return a non-action
      return "Invalid request - #{card.readable_name} is not a Treasure"
    end

    # All good. put the chosen card on top of the deck
    card.location = "deck"
    card.position = -1
    card.save!

    game.histories.create(:event => "#{ply.name} put #{card} on top of his deck with #{self}.",
                          :css_class => "player#{ply.seat}")

    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      treasures = ply.cards.in_play.select(&:is_treasure?)
      raise "Wrong number of in-play treasures" unless treasures.count == 1
      card = treasures[0]
      card.location = "deck"
      card.position = -2
      card.save!
      game.histories.create!(:event => "#{ply.name} placed #{card} on top of their deck with #{self}.",
                            :css_class => "player#{ply.seat}")
    end

    return "OK"
  end
end