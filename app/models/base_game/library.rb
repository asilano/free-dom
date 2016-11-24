class BaseGame::Library < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw until you have 7 cards in hand. You may set " +
                       "aside any Action cards you draw this way, as you " +
                       "draw them; discard the set-aside cards after you " +
                       "finish drawing."

  SetAsideJournalTempl = Journal::Template.new("{{player}} chose '{{choice}}' for {{card}} with #{readable_name}.")

  def play
    super

    # Library is heavily re-entrant, so we'll put its processing in a "clean"
    # subfunction
    process
  end

  # Function to handle the actions dictated by Library. Expected to be called
  # by both play() and resolve_choice()
  def process
    # Assume we're just going to draw up to 7 cards; we'll break out of the loop
    # if we hit an action
    num_to_draw = 7 - player.cards.hand.size
    clear_up = true

    1.upto(num_to_draw) do |n|
      drawn = player.draw_cards(1)

      # If we didn't actually draw a card - so deck and discard are empty - give
      # up (or we'd just loop a bit more than we want).
      break if drawn.length == 0

      if drawn[0].is_action?
        # Drawn an action. Ask whether we should set this card aside.
        set_aside_journal = game.find_journal_or_ask(template: Journal::Template.new(SetAsideJournalTempl.fill(player: player.name)),
                                                      qn_params: {object: self, actor: player,
                                                                  method: :resolve_choose,
                                                                  text: "Set aside or keep a card with #{readable_name}."
                                                                  })
        resolve_choose(set_aside_journal, player)
      end
    end

    if clear_up
      discard_set_aside
    end
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_choose
      # Player deciding whether to keep or set aside a drawn action.
      # Technically, this would make sense as a Radio Button control - but that
      # needs two clicks, and is likely to get irritating.
      last_card = actor.cards.hand.last
      last_ix = actor.cards.hand.length - 1
      controls[:hand] += [{:type => :button,
                          :text => "Set aside",
                          :nil_action => [{text: "Keep",
                                           journal: "#{actor.name} chose 'keep' for #{last_card.readable_name} (#{last_ix}) with #{readable_name}.",
                                           hidden: true}],
                          :journals => ([nil] * (player.cards.hand.size - 1)) +
                                       ["#{actor.name} chose 'set aside' for #{last_card.readable_name} (#{last_ix}) with #{readable_name}."]
                         }]
    end
  end

  resolves(:choose).using(SetAsideJournalTempl).
                    validating_param_is_card(:card, scope: :hand) { |card| card.class == card.player.cards.hand.last.class }.
                    validating_params_has(:choice).
                    validating_param_value_in(:choice, 'set aside', 'keep').
                    with do
    if journal.choice == 'set aside'
      card = actor.cards.hand.last
      actor.cards.revealed << card
      card.location = "library"
      card.revealed = true
    end

    # Carry on processing
    process
  end

  def discard_set_aside
    # Move all revealed cards to Discard, and unreveal them
    # Force a reload of all affected areas
    player.cards.revealed.each do |card|
      card.discard
    end
  end

end
