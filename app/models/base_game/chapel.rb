class BaseGame::Chapel < Card
  costs 2
  action
  card_text "Action (cost: 2) - Trash up to 4 cards from your hand."

  module Journals
    class TrashJournal < Journal
      causes :trash_chosen
      validates_hash_keys :parameters do
        validates_each_in_array :card_id do
          validates :value, card: { owner: :actor, location: :hand, allow_nil: true }
        end
      end
      text do
        if parameters[:card_id].empty?
          "#{player.name} trashed nothing with Chapel."
        else
          cards = parameters[:card_id].map { |cid| game.find_card(cid).readable_name }
          "#{player.name} trashed #{cards.join(', ')} with Chapel."
        end
      end
      question(text: 'Trash up to 4 cards with Chapel') do
        {
          hand: {
            type: :checkboxes,
            choice_text: 'Trash',
            button_text: 'Trash selected',
            parameters: cards.hand.map(&:id)
          }
        }
      end
    end
  end

  def play
    super

    if player.cards.hand.empty?
      # Holding no cards. Just log
      game.add_history(:event => "#{player.name} trashed nothing with #{readable_name}.",
                        :css_class => "player#{player.seat} card_trash")
      return
    end

    # Ask for a set of trashes
    game.ask_question(object: self, actor: player, journal: Journals::TrashJournal)
  end

  def trash_chosen(journal)
    # All checks out. Carry on
    if !journal.cards.empty?
      # Trash each selected card
      journal.cards.each(&:trash)
    end
  end
end
