class BaseGame::Bureaucrat < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Gain a Silver card; put it on top of your deck. " +
                               "Each other player reveals a Victory card from " +
                               "his or her hand and puts it on top of their " +
                               "deck, or reveals a hand with no Victory cards."

  module Journals
    class PlaceVictoryJournal < Journal
      causes :place_victory
      validates_hash_keys :parameters do
        validates :card_id, card: { owner: :actor, location: :hand, satisfies: :is_victory? }
      end
      text do
        card = game.find_card(parameters[:card_id])
        "#{player.name} put #{card.readable_name} on top of their deck."
      end
      question(text: 'Place a victory card onto deck') do
        {
          hand: {
            type: :button,
            text: 'Place',
            parameters: cards.hand.map { |c| c.id if c.is_victory? }
          }
        }
      end
    end
  end

  def play
    super

    # First, acquire a Silver to top of deck.
    silver = game.cards.pile.of_type('BasicCards::Silver').first
    player.gain(silver, game.current_journal, location: 'deck')

    game.add_history(:event => "#{player.name} gained a Silver to top of their deck.",
                      :css_class => "player#{player.seat} card_gain")

    # Now, attack
    attack
  end

  def attackeffect(journal)
    # Effect of the attack succeeding - that is, ask the target to put a Victory
    # card on top of their deck.
    target = Player.find(journal.parameters[:victim_id])

    # Check for the hand having no Victory cards. Then there is no question to ask.
    target_victories = target.cards.hand.select(&:is_victory?)
    if target_victories.empty?
      # Target is holding no victories. Just log the "revealing" of the hand
      game.add_history(:event => "#{target.name} revealed their hand to the Bureaucrat:",
                        :css_class => "player#{target.seat} card_reveal")
      game.add_history(:event => "#{target.name} revealed #{target.cards.hand.map(&:readable_name).join(', ')}.",
                        :css_class => "player#{target.seat} card_reveal")
      return
    end

    # Ask the required question
    q = game.ask_question(object: self,
                          actor: target,
                          journal: Journals::PlaceVictoryJournal)

    if game.find_journal(q[:template]).nil?
      # See if autocrat lets us pre-create the journal.
      if (target.settings.autocrat_victory &&
          target_victories.map(&:class).uniq.length == 1)
        # Target is autocratting victories, and holding exactly one type of
        # victory card. Find the index of that card, and pre-create the journal
        vic = target_victories[0]
        game.add_journal(type: Journals::PlaceVictoryJournal.to_s,
                         player: target,
                         parameters: { card_id: vic.id })
      end
    end

  end

  # This is at the attack target putting a card back on their deck.
  def place_victory(journal)
    # Place the specified card on top of the player's deck, and "reveal" it by creating a history.
    card = journal.card
    card.location = "deck"
    card.position = -1
    journal.player.renum(:deck)
  end
end
