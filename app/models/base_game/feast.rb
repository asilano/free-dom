class BaseGame::Feast < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this card. Gain a card costing up to 5."

  TakeEventTempl = Journal::Template.new("{{player}} took {{card}} with #{readable_name}.")

  def play
    super

    # Store off the current owner, and trash this card
    owner = player
    trash

    # Ask for which card to gain
    journal = game.find_journal(TakeEventTempl)

    if journal.nil?
      if game.piles.all? { |pile| pile.empty? || pile.cost > 5 }
        # No cards cheap enough to take. Just log
        game.add_history(event: "#{owner.name} took nothing with #{readable_name}.",
                          css_class: "player#{owner.seat} card_gain")
      else
        # Ask the required question, and escape this processing stack
        game.ask_question(object: self, actor: owner, method: :resolve_take, text: "Take a card with #{readable_name}.")
        game.abort_journal
      end
    end

    if journal
      resolve_take(journal, owner)
    end
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_take
      journals = game.piles.map do |pile|
        if pile.cost <= 5 && !pile.empty?
          TakeEventTempl.fill(player: actor.name, card: pile.cards[0].readable_name)
        else
          nil
        end
      end
      controls[:piles] += [{:type => :button,
                            :text => "Take",
                            :nil_action => nil,
                            journals: journals
                          }]
    end
  end

  resolves(:take).using(TakeEventTempl).
                 validating_param_is_card(:card, scope: :supply) { cost <= 5 }.
                 with do
    # Process the take.
    actor.gain(:card => journal.card, journal: journal)
  end
end
