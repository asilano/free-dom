module GameEngine
  module Renaissance
    class Villain < Card
      text "+2 Coffers",
           "Each other player with 5 or more cards in hand discards one costing $2 or more (or reveals they can't)."
      action
      attack
      costs 5

      def play_as_action(played_by:)
        super

        played_by.coffers += 2
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        # Skip players with too-small hands (can do so silently)
        return unless victim.hand_cards.length >= 5

        if victim.hand_cards.none? { _1.cost >= 1 }
          # Reveal hand (actually, because of Patron); then immediately unreveal
          victim.reveal_cards(:all, from: :hand).each do |card|
            card.be_unrevealed if card.revealed
          end
        else
          game_state.get_journal(DiscardJournal, from: victim).process(game_state)
        end
      end

      class DiscardJournal < Journal
        define_question("Discard a card costing $2 or more").with_controls do |_game_state|
          [OneCardControl.new(journal_type: DiscardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         "Discard",
                              filter:       ->(card) { card.cost >= 2 },
                              css_class:    "discard-card")]
        end

        validation do
          return false unless params["choice"]&.integer?

          choice = params["choice"].to_i
          choice < player.hand_cards.length &&
            player.hand_cards[choice].cost >= 2
        end

        process do |_game_state|
          # Have the player discard the chosen card
          card = player.hand_cards[params["choice"].to_i]
          @histories << History.new("#{player.name} discarded #{card.readable_name}.",
                                    player:      player,
                                    css_classes: %w[discard-card])
          card.discard
          observe
        end
      end
    end
  end
end
