module GameEngine
  module CardShapedThings
    module Projects
      class Silos < Project
        text "At the start of your turn, discard any number of Coppers, revealed, and draw that many cards."
        costs 4

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)
            game_state.get_journal(DiscardCoppersJournal, from: turn_player).process(game_state)
          end
        end

        class DiscardCoppersJournal < Journal
          define_question("Discard any number of Coppers").with_controls do |_game_state|
            [MultiCardControl.new(journal_type: DiscardCoppersJournal,
                                  question:     self,
                                  player:       @player,
                                  scope:        :hand,
                                  filter:       ->(card) { card.is_a? BasicCard::Copper },
                                  text:         "Discard",
                                  submit_text:  "Discard selected cards",
                                  css_class:    "discard")]
          end

          validation do
            return true if params["choice"].blank?
            return false unless params["choice"]&.all?(&:integer?)

            params["choice"].all? do |choice|
              player.hand_cards[choice.to_i].is_a? BasicCards::Copper
            end
          end

          process do |game_state|
            # Just log if the player chose nothing
            if params["choice"].blank?
              @histories << History.new("#{player.name} discarded nothing",
                                        player:      player,
                                        css_classes: %w[discard])
              return
            end

            # Discard all the chosen cards in hand order
            cards = params["choice"].map { |ch| player.hand_cards[ch.to_i] }
            cards.each(&:discard)
            @histories << History.new("#{player.name} discarded #{pluralize(cards.length, "Copper")}.",
                                      player:      player,
                                      css_classes: %w[discard])

            game_state.observe

            # Draw that many replacements
            player.draw_cards(cards.length)
          end
        end
      end
    end
  end
end
