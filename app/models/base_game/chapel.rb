class BaseGame::Chapel < Card
  costs 2
  action
  card_text "Action (cost: 2) - Trash up to 4 cards from your hand."

  TrashEventTempl = Journal::Template.new("{{player}} trashed {{cards}} with #{readable_name}.")

  def play
    super

    if player.cards.hand.empty?
      # Holding no cards. Just log
      game.add_history(:event => "#{player.name} trashed no cards with #{readable_name}.",
                        :css_class => "player#{player.seat} card_trash")
      return
    end

    # Ask for a set of trashes
    game.ask_question(object: self, actor: player, method: :resolve_trash, text: "Trash up to 4 cards with #{readable_name}.")
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_trash
      controls[:hand] += [{:type => :checkboxes,
                           :name => "trash",
                           :choice_text => "Trash",
                           :button_text => "Trash selected",
                           journal_template: TrashEventTempl.fill(player: actor.name),
                           journals: actor.cards.hand.each_with_index.map { |c, ix| "#{c.readable_name} (#{ix})" },
                           field_name: :cards,
                           if_empty: {cards: 'nothing'},
                           validate: {max_count: 4}
                          }]
    end
  end

  resolves(:trash).using(TrashEventTempl).
                   validating_param_is_card_array(:cards, scope: :hand,
                                                   allow_blank_with: 'nothing',
                                                   max_count: 4).
                   with do
    # All checks out. Carry on
    if !journal.cards.empty?
      # Trash each selected card
      journal.cards.each(&:trash)
    end
  end
end
