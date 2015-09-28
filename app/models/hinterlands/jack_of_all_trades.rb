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
                     :game => game).queue(
                    :expected_action => "resolve_#{self.class}#{id}_triggerdraw",
                     :game => game).queue(
                    :expected_action => "resolve_#{self.class}#{id}_triggertrash",
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

  resolves(:discard).validating_params_has(:choice).
                      validating_param_value_in(:choice, 'discard', 'leave').
                      with do
    # Everything looks fine. Carry out the requested choice
    card = actor.cards(true).deck.first
    if params[:choice] == "leave"
      # Chose not to discard the card, so a no-op other than unpeeking.
      card.peeked = false
      card.save!

      # Create a history
      game.histories.create!(:event => "#{actor.name} chose not to discard the top card of their deck.",
                            :css_class => "player#{actor.seat}")

    else
      # Discard the card
      card.discard

      # And create a history
      game.histories.create!(:event => "#{actor.name} discarded #{card} from the top of their deck.",
                            :css_class => "player#{actor.seat}")
    end
    "OK"
  end

  def triggerdraw(params)
    num_to_draw = 5 - player.cards(true).hand.count

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

  resolves(:trash).validating_params_has_any_of(:card_index, :nil_action).
                    validating_param_is_card(:card_index, scope: :hand) { !is_treasure? }.
                    with do
    if params[:nil_action]
      # No trash. Just log
      game.histories.create!(:event => "#{actor.name} trashed nothing.",
                             :css_class => "player#{actor.seat}")
    else
    # Trash the selected card, and log
      card = actor.cards.hand[params[:card_index].to_i]
      card.trash
      game.histories.create!(:event => "#{actor.name} trashed a #{card} from hand).",
                            :css_class => "player#{actor.seat} card_trash")
    end

    "OK"
  end
end