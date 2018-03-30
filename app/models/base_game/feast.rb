class BaseGame::Feast < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this card. Gain a card costing up to 5."

  module Journals
    class TakeJournal < Journal
      causes :take_card
      validates_hash_keys :parameters do
        validates :card_id, card: { location: :pile, allow_nil: false,
                                    satisfies: ->(card, journal){ card.position == 0 && card.cost <= 5 },
                                    satisfy_msg: 'is not an affordable card on top of a pile.' }
      end
      text { "#{player.name} took #{card.readable_name} with Feast." }
      question(text: 'Take a card with Feast') do
        {
          piles: {
            type: :button,
            text: 'Take',
            parameters: game.piles.map { |p| c = p.cards.first; c.id if c && c.cost <= 5 }
          }
        }
      end
    end
  end

  def play
    super

    # Store off the current owner, and trash this card
    owner = player
    trash

    if game.piles.all? { |pile| pile.empty? || pile.cost > 5 }
      # No cards cheap enough to take. Just log
      game.add_history(event: "#{owner.name} took nothing with #{readable_name}.",
                        css_class: "player#{owner.seat} card_gain")
      return
    end

    # Ask for which card to gain
    game.ask_question(object: self, actor: owner, journal: Journals::TakeJournal)
  end

  def take_card(journal)
    # Process the take.
    journal.player.gain(journal.card, journal)
  end
end
