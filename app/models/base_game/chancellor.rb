class BaseGame::Chancellor < Card
  costs 3
  action
  card_text "Action (cost: 3) - +2 Cash. You may immediately put your deck into your " +
                        "discard pile."

  ChooseEventTempl = Journal::Template.new("{{player}} chose to {{choice}} their deck with #{readable_name}.")

  def play
    super

    # Easy bit first. Add two cash
    player.cash += 2

    journal = game.find_journal(ChooseEventTempl)

    if journal.nil?
      # Ask the required question, and escape this processing stack
      game.ask_question(object: self, actor: player, method: :resolve_trash, text: "Choose whether to discard your deck, with #{readable_name}.")
      game.abort_journal
    end

    if journal
      resolve_choose(journal, player)
    end
  end

  def determine_controls(actor, controls, question)
    controls[:player] += [{type: :buttons,
                           label: "#{readable_name}:",
                           options: [{text: "Discard deck", journal: ChooseEventTempl.fill(player: actor.name, choice: 'discard')},
                                      {text: "Don't discard", journal: ChooseEventTempl.fill(player: actor.name, choice: 'keep')}]
                           }]
  end

  resolves(:choose).using(ChooseEventTempl).
                    validating_params_has(:choice).
                    validating_param_value_in(:choice, 'discard', 'keep').
                    with do
    # Everything looks fine. Carry out the requested choice
    if journal.choice == "discard"
      actor.cards.deck.each do |card|
        # Move card to discard _without tripping callbacks_
        card.location = 'discard'
      end
    end
  end
end
