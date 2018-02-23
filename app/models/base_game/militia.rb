class BaseGame::Militia < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - +2 Cash. Each other player discards down " +
                                        "to 3 cards."

  module Journals
    class DiscardJournal < Journal
      causes :discard_card
      validates_hash_keys :parameters do
        validates :card_id, card: { owner: :actor, location: :hand }
      end
      text do
        card = game.find_card(parameters[:card_id])
        "#{player.name} discarded #{card.readable_name}."
      end
      question(text: -> { "Discard #{@count} #{'card'.pluralize @count} with Militia" }) do
        {
          hand: {
            type: :button,
            text: 'Discard',
            parameters: cards.hand.map(&:id)
          }
        }
      end.class_eval do
        def set_count(count)
          @count = count
        end
      end
    end
  end

  def play
    super

    # Grant the player 2 cash
    player.cash += 2

    # Then conduct the attack
    attack
  end

  def attackeffect(journal)
    # Effect of the attack succeeding - that is, ask the target to discard
    # enough cards to reduce their hand to 3.
    target = Player.find(journal.parameters[:victim_id])
    ask_next_discard_question(target)
  end

  def discard_card(journal)
    # Discard selected card
    journal.card.discard

    # See if the target still needs to discard
    ask_next_discard_question(journal.player)
  end

  private

  def ask_next_discard_question(target)
    # Determine how many cards to discard - never negative
    num_discards = target.cards.hand.size - 3
    if num_discards <= 0
      return
    end

    q = game.ask_question(object: self, actor: target, journal: Journals::DiscardJournal)
    q[:question].set_count(num_discards)
  end
end
