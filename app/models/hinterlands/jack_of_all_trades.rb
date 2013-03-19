class Hinterlands::JackOfAllTrades < Card
  action
  costs 4
  card_text "Action (cost: 4) - Gain a Silver. Look at the top card of your deck; discard it or put it back. " +
            "Draw until you have 5 cards in hand. You may trash a card from your hand that is not a Treasure."

  def self.readable_name
    "Jack of all Trades"
  end

  def play(parent_act)
    super

    # Create pending actions for the last 3 steps, and kick off a gain.
    # Technically, the "draw to 5" part doesn't need a triggering action, but
    # this way it's clearer what we're doing.
    silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
    player.gain(parent_act, :pile => silver_pile)
    parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_triggerpeek",
                     :game => game)
    parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_triggerdraw",
                     :game => game)
    parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_triggertrash",
                     :game => game)

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => "#{readable_name}:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "discard"},
                             :options => [{:text => "Discard #{player.cards.peeked[0]}",
                                           :choice => "discard"},
                                          {:text => "Don't discard #{player.cards.peeked[0]}",
                                           :choice => "leave"}]
                            }]
    when "trash"
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Trash",
                           :nil_action => "Trash nothing",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "trash"},
                           :cards => player.cards.hand.map {|c| !c.is_treasure?}
                          }]
    end
  end

  def triggerpeek(params)
    parent_act = params[:parent_act]
    # Peek at the top card of the player's deck.
    seen = player.peek_at_deck(1)

    # If they actually saw a card, ask if they want to discard it
    unless seen.empty?
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                  :text => "Choose whether to discard #{seen[0]}",
                                  :player => player,
                                  :game => game)
    end

    "OK"
  end

  def resolve_discard(ply, params, parent_act)
    # We expect to have a :choice parameter, either "discard" or "leave"
    if (not params.include? :choice) or
       (not params[:choice].in? ["discard", "leave"])
      return "Invalid parameters"
    end

    # Everything looks fine. Carry out the requested choice
    card = ply.cards.deck(true).first
    if params[:choice] == "leave"
      # Chose not to discard the card, so a no-op other than unpeeking.
      card.peeked = false
      card.save!

      # Create a history
      game.histories.create!(:event => "#{ply.name} chose not to discard the top card of their deck.",
                            :css_class => "player#{ply.seat}")

    else
      # Discard the card
      card.discard

      # And create a history
      game.histories.create!(:event => "#{ply.name} discarded #{card} from the top of their deck.",
                            :css_class => "player#{ply.seat}")
    end
    return "OK"
  end

  def triggerdraw(params)
    num_to_draw = 5 - player.cards.hand(true).count

    if num_to_draw > 0
      player.draw_cards(num_to_draw)
    else
      # Log that the player was already at 5.
      game.histories.create!(:event => "#{player.name} drew no cards from #{self}.",
                            :css_class => "player#{player.seat}")
    end

    return "OK"
  end

  def triggertrash(params)
    parent_act = params[:parent_act]

    if player.cards.hand.reject {|c| c.is_treasure?}.empty?
      # Player isn't holding any non-treasures. Just call resolve_trash directly to log
      resolve_trash(player, {:nil_action => true}, parent_act)
    else
      # Queue a proper action to ask about the trash.
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                  :text => "Optionally trash a non-treasure",
                                  :player => player,
                                  :game => game)
    end

    "OK"
  end

  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include?(:card_index) && !params.include?(:nil_action)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if (params.include?(:card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to trash an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include?(:card_index) &&
          ply.cards.hand[params[:card_index].to_i].is_treasure?
      # Asked to trash an invalid card (is a treasure)
      return "Invalid request - card index #{params[:card_index]} is a treasure"
    end

    # All checks out. Carry on

    if params[:nil_action]
      # No trash. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing.",
                             :css_class => "player#{player.seat}")
    else
    # Trash the selected card, and log
      card = ply.cards.hand[params[:card_index].to_i]
      card.trash
      game.histories.create!(:event => "#{ply.name} trashed a #{card} from hand).",
                            :css_class => "player#{ply.seat} card_trash")
    end

    return "OK"
  end
end