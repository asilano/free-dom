class BaseGame::Cellar < Card
  costs 2
  action
  card_text "Action (cost: 2) - +1 Action. Discard any number of cards. Draw 1 card " +
                       "per card discarded."

  module Journals
    class DiscardJournal < Journal
      causes :discard_for_draw
      validates_hash_keys :parameters do
        validates_each_in_array :card_id do
          validates :value, card: { owner: :actor, location: :hand, allow_nil: true }
        end
      end
      text do
        if parameters[:card_id].empty?
          "#{player.name} discarded no cards to Cellar."
        else
          cards = parameters[:card_id].map { |cid| game.find_card(cid).readable_name }
          "#{player.name} discarded #{cards.join(', ')} to Cellar."
        end
      end
      question(text: 'Discard any number of cards with Cellar') do
        {
          hand: {
            type: :checkboxes,
            choice_text: 'Discard',
            button_text: 'Discard selected',
            parameters: cards.hand.map(&:id)
          }
        }
      end
    end
  end

  def play
    super

    # Grant the player another action
    player.add_actions(1)

    # Check for the player holding no cards. If so, there's no question to ask
    if player.cards.hand.empty?
      # Holding no cards. Just log
      game.add_history(:event => "#{player.name} discarded no cards to #{readable_name}.",
                        :css_class => "player#{player.seat} card_discard")
      return
    end


    # Ask the required question
    game.ask_question(object: self, actor: player, journal: Journals::DiscardJournal)
  end

  def discard_for_draw(journal)
    if !journal.cards.empty?
      # Discard each selected card
      journal.cards.each(&:discard)

      # Draw the same number of replacement cards
      journal.player.draw_cards(journal.cards.count)
    end
  end
end
