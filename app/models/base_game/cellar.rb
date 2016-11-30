class BaseGame::Cellar < Card
  costs 2
  action
  card_text "Action (cost: 2) - +1 Action. Discard any number of cards. Draw 1 card " +
                       "per card discarded."

  DiscardEventTempl = Journal::Template.new("{{player}} discarded {{cards}} with #{readable_name}.")

  def play
    super

    # Grant the player another action
    player.add_actions(1)

    # And ask for a set of discards
    journal = game.find_journal(DiscardEventTempl)

    if journal.nil?
      if player.cards.hand.empty?
        # Holding no cards. Just log
        game.add_history(:event => "#{player.name} discarded no cards to #{readable_name}.",
                          :css_class => "player#{player.seat} card_discard")
      else
        # Ask the required question, and escape this processing stack
        game.ask_question(object: self, actor: player, method: :resolve_discard, text: "Discard any number of cards with #{readable_name}.")
        game.abort_journal
      end
    end

    if journal
      resolve_discard(journal, player)
    end
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_discard
      controls[:hand] += [{:type => :checkboxes,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           journal_template: DiscardEventTempl.fill(player: actor.name),
                           journals: actor.cards.hand.each_with_index.map { |c, ix| "#{c.readable_name} (#{ix})" },
                           field_name: :cards,
                           if_empty: {cards: 'nothing'}
                          }]
    end
  end

  resolves(:discard).using(DiscardEventTempl).
                      validating_param_is_card_array(:cards, scope: :hand, allow_blank_with: 'nothing').with do
    # Looks good.
    if !journal.cards.empty?
      # Discard each selected card
      journal.cards.each(&:discard)

      # Draw the same number of replacement cards
      actor.draw_cards(journal.cards.count)
    end
  end
end
