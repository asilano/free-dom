class BaseGame::Bureaucrat < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Gain a Silver card; put it on top of your deck. " +
                               "Each other player reveals a Victory card from " +
                               "his or her hand and puts it on top of their " +
                               "deck, or reveals a hand with no Victory cards."

  PlaceEventTempl = Journal::Template.new("{{player}} put {{card}} on top of their deck.")

  def play
    super

    # First, acquire a Silver to top of deck.
    silver_pile = game.piles.detect { |pile| pile.card_type == "BasicCards::Silver" }
    player.gain(pile: silver_pile, location: "deck", journal: game.current_journal)

    game.add_history(:event => "#{player.name} gained a Silver to top of their deck.",
                      :css_class => "player#{player.seat} card_gain")

    # Now, attack
    attack
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_victory
      # Ask the attack target for a Victory card, or to reveal a hand devoid of
      # all such.
      controls[:hand] += [{type: :button,
                            text: "Place",
                            nil_action: nil,
                            journals: actor.cards.hand.each_with_index.map do |c, ix|
                              PlaceEventTempl.fill(player: actor.name, card: "#{c.readable_name} (#{ix})") if c.is_victory?
                            end
                          }]
    end
  end

  resolves(:attack).using(AttackTempl).with do
    # Effect of the attack succeeding - that is, ask the target to put a Victory
    # card on top of their deck.
    target = Player.find(journal.params[:victim])

    # Check for the hand having no Victory cards. Then there is no question to ask.
    target_victories = target.cards.hand.select { |c| c.is_victory? }
    if target_victories.empty?
      # Target is holding no victories. Just log the "revealing" of the hand
      game.add_history(:event => "#{target.name} revealed their hand to the Bureaucrat:",
                        :css_class => "player#{target.seat} card_reveal")
      game.add_history(:event => "#{target.name} revealed #{target.cards.hand.map(&:readable_name).join(', ')}.",
                        :css_class => "player#{target.seat} card_reveal")
      return
    end

    target_journal_templ = Journal::Template.new(PlaceEventTempl.fill(player: target.name))
    if game.find_journal(target_journal_templ).nil?
      # See if autocrat lets us pre-create the journal.
      if (target.settings.autocrat_victory &&
          target_victories.map(&:class).uniq.length == 1)
        # Target is autocratting victories, and holding exactly one type of
        # victory card. Find the index of that card, and pre-create the journal
        vic = target_victories[0]
        index = target.cards.hand.index(vic)
        game.add_journal(player_id: target.id,
                          event: target_journal_templ.fill(card: "#{vic.readable_name} (#{index})"))
      end
    end

    # Ask the required question
    game.ask_question(object: self, actor: target, method: :resolve_victory, text: "Place a Victory card onto deck.")
  end

  # This is at the attack target either putting a card back on their deck,
  # or revealing a hand devoid of victory cards.
  resolves(:victory).using(PlaceEventTempl).
                   validating_param_is_card(:card, scope: :hand, &:is_victory?).
                   with do
    # Place the specified card on top of the player's deck, and "reveal" it by creating a history.
    card = journal.card
    card.location = "deck"
    card.position = -1
    actor.renum(:deck)
    game.add_history(:event => "#{actor.name} put a #{card.class.readable_name} on top of their deck.",
                      :css_class => "player#{actor.seat}")
  end
end
